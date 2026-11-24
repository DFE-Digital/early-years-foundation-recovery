require 'rails_helper'

RSpec.describe ContentfulResponseCache do
  let(:cache) { ActiveSupport::Cache::MemoryStore.new }
  let(:configuration) do
    {
      space: 'cache-test-space',
      environment: 'cache-test-environment',
      access_token: 'delivery-token',
      preview_access_token: 'preview-token',
      dynamic_entries: :manual,
      entry_mapping: { 'static' => Page },
      max_rate_limit_retries: 1,
    }
  end
  let(:client) { ContentfulModel::Client.new(configuration.dup) }
  let(:body) do
    {
      sys: { type: 'Array' },
      total: 1,
      items: [{
        sys: {
          id: 'sitemap',
          type: 'Entry',
          space: { sys: { type: 'Link', linkType: 'Space', id: 'cache-test-space' } },
          contentType: { sys: { type: 'Link', linkType: 'ContentType', id: 'static' } },
        },
        fields: { name: 'sitemap', heading: 'Sitemap' },
      }],
    }.to_json
  end
  let(:response) { HTTP::Response.new(status: 200, version: '1.1', body: body) }
  let(:http_client) { instance_double(HTTP::Client, get: response) }

  before do
    Training::Module.cache.clear
    allow(Rails).to receive(:cache).and_return(cache)
    allow(ContentfulModel).to receive(:use_preview_api).and_return(false)
    allow(HTTP).to receive(:[]).and_return(http_client)
  end

  after { Training::Module.cache.clear }

  it 'shares responses between independent clients and rebuilds mapped model objects' do
    first = client.entries(content_type: 'static').first
    second_client = ContentfulModel::Client.new(configuration.dup)
    second = second_client.entries(content_type: 'static').first

    expect(first).to be_a(Page)
    expect(second).to be_a(Page)
    expect(second.title).to eq('Sitemap')
    expect(second).not_to equal(first)
    expect(http_client).to have_received(:get).once
  end

  it 'serves page lookups from the shared cache after clearing the in-process cache' do
    allow(Page).to receive(:client).and_return(client)
    Page.by_name('sitemap')
    Training::Module.cache.clear

    expect(Page.by_name('sitemap').title).to eq('Sitemap')
    expect(http_client).to have_received(:get).once
  end

  it 'rebuilds linked entries from cached responses' do
    linked_body = JSON.parse(body)
    linked_body['items'].first['fields']['related'] = {
      'sys' => { 'type' => 'Link', 'linkType' => 'Entry', 'id' => 'child-page' },
    }
    linked_body['includes'] = {
      'Entry' => [{
        'sys' => linked_body['items'].first['sys'].merge('id' => 'child-page'),
        'fields' => { 'name' => 'child', 'heading' => 'Child page' },
      }],
    }
    allow(http_client).to receive(:get).and_return(
      HTTP::Response.new(status: 200, version: '1.1', body: linked_body.to_json),
    )
    client.entries

    expect(client.entries.first.related.title).to eq('Child page')
    expect(http_client).to have_received(:get).once
  end

  it 'does not store access tokens in cache keys or values' do
    client.entries
    key = Contentful::Client.send(
      :response_cache_key,
      'https://cdn.contentful.com/spaces/cache-test-space/environments/cache-test-environment/entries',
      nil,
      'Authorization' => "Bearer #{configuration[:access_token]}",
    )

    expect(key.join('/')).not_to include(configuration[:access_token])
    expect(cache.read(key)).to be_present
    expect(cache.read(key).to_json).not_to include(configuration[:access_token])
  end

  it 'isolates queries, spaces, environments and access tokens' do
    client.entries(content_type: 'static')
    client.entries(content_type: 'resource')

    [
      { space: 'another-space' },
      { environment: 'another-environment' },
      { access_token: 'another-token' },
    ].each do |override|
      ContentfulModel::Client.new(configuration.merge(override)).entries(content_type: 'static')
    end

    expect(http_client).to have_received(:get).exactly(5).times
  end

  it 'caches preview responses separately from delivery responses' do
    client.entries
    allow(ContentfulModel).to receive(:use_preview_api).and_return(true)

    preview_client = ContentfulModel::Client.new(configuration.dup)
    preview_client.entries
    preview_client.entries

    expect(http_client).to have_received(:get).twice
  end

  it 'does not cache management or lookalike delivery hosts' do
    %w[api.contentful.com cdn.contentful.com.example.org].each do |host|
      other_client = ContentfulModel::Client.new(configuration.merge(api_url: host))
      other_client.entries
      other_client.entries
    end

    expect(http_client).to have_received(:get).exactly(4).times
  end

  it 'is a no-op with a null cache store' do
    allow(Rails).to receive(:cache).and_return(ActiveSupport::Cache::NullStore.new)

    client.entries
    client.entries

    expect(http_client).to have_received(:get).twice
  end

  it 'reuses equivalent queries regardless of parameter order' do
    client.entries(content_type: 'static', limit: 1)
    client.entries(limit: 1, content_type: 'static')

    expect(http_client).to have_received(:get).once
  end

  it 'preserves compressed responses when reading from the shared cache' do
    compressed = StringIO.new
    Zlib::GzipWriter.wrap(compressed) { |gzip| gzip.write(body) }
    allow(http_client).to receive(:get).and_return(
      HTTP::Response.new(
        status: 200,
        version: '1.1',
        headers: { 'Content-Encoding' => 'gzip' },
        body: compressed.string,
      ),
    )

    client.entries

    expect(client.entries.first.title).to eq('Sitemap')
    expect(http_client).to have_received(:get).once
  end

  it 'expires cached responses' do
    client.entries

    travel 1.hour + 11.seconds do
      client.entries
    end

    expect(http_client).to have_received(:get).twice
  end

  it 'invalidates responses for releases created within the same minute' do
    freeze_time do
      create :release
      Page.reset_cache_key!
      client.entries
      create :release
      Page.reset_cache_key!
      client.entries
    end

    expect(http_client).to have_received(:get).twice
  end

  it 'leaves unrelated Rails cache entries intact when content changes' do
    cache.write('jwks', 'signing-keys')
    client.entries
    create :release
    Page.reset_cache_key!
    client.entries

    expect(cache.read('jwks')).to eq('signing-keys')
  end

  it 'uses the latest release version when running a content check' do
    client.entries
    create :release
    job = ContentCheckJob.new({})
    allow(job).to receive(:valid?) do
      client.entries
      true
    end

    job.run

    expect(http_client).to have_received(:get).twice
  end

  it 'does not cache API errors' do
    error_response = HTTP::Response.new(status: 500, version: '1.1', body: '')
    allow(http_client).to receive(:get).and_return(error_response, response)

    expect { client.entries }.to raise_error(Contentful::Error)
    expect(client.entries.first.title).to eq('Sitemap')
    expect(http_client).to have_received(:get).twice
  end

  it 'preserves SDK rate-limit retries without caching the 429 response' do
    rate_limited = HTTP::Response.new(
      status: 429,
      version: '1.1',
      headers: { 'X-Contentful-RateLimit-Reset' => '1' },
      body: '',
    )
    allow(http_client).to receive(:get).and_return(rate_limited, response)
    allow(client).to receive(:sleep)

    expect(client.entries.first.title).to eq('Sitemap')
    expect(client.entries.first.title).to eq('Sitemap')
    expect(client).to have_received(:sleep).once
    expect(http_client).to have_received(:get).twice
  end

  it 'surfaces exhausted rate-limit retries and retries the API on the next call' do
    rate_limited = HTTP::Response.new(
      status: 429,
      version: '1.1',
      headers: { 'X-Contentful-RateLimit-Reset' => '1' },
      body: '',
    )
    allow(http_client).to receive(:get).and_return(rate_limited, rate_limited, response)
    allow(client).to receive(:sleep)

    expect { client.entries }.to raise_error(Contentful::RateLimitExceeded)
    expect(client.entries.first.title).to eq('Sitemap')
    expect(http_client).to have_received(:get).exactly(3).times
  end
end
