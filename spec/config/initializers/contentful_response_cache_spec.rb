require 'rails_helper'

RSpec.describe ContentfulResponseCache do
  subject(:request) { client.get_http(url, { content_type: 'static' }) }

  let(:url) { 'https://cdn.contentful.com/spaces/space/environments/master/entries' }
  let(:response) do
    Struct.new(:status, :body, :headers) do
      delegate :to_s, to: :body
    end.new(200, '{"items":[]}', { 'Content-Encoding' => 'gzip' })
  end
  let(:client_class) do
    Class.new do
      attr_reader :requests

      def initialize(response)
        @response = response
        @requests = 0
      end

      def get_http(_url, _query, _headers = {}, _proxy = {}, _timeout = {})
        @requests += 1
        @response
      end

      prepend ContentfulResponseCache
    end
  end
  let(:client) { client_class.new(response) }

  around do |example|
    original_cache = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    example.run
  ensure
    Rails.cache = original_cache
  end

  before { allow(Page).to receive(:cache_key).and_return('version') }

  it 'shares successful delivery responses through Rails.cache' do
    first_response = request
    second_response = request

    expect(client.requests).to eq 1
    expect(first_response.to_s).to eq '{"items":[]}'
    expect(second_response.to_s).to eq '{"items":[]}'
  end

  it 'does not cache non-successful responses' do
    response.status = 429

    2.times { request }

    expect(client.requests).to eq 2
  end

  it 'does not cache Contentful preview responses' do
    allow(client).to receive(:cacheable_contentful_request?).and_return(false)

    2.times { request }

    expect(client.requests).to eq 2
  end
end
