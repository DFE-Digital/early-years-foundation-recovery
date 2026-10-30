require 'rails_helper'

RSpec.describe 'Content Security Policy' do
  subject(:directives) do
    Rails.application.config.content_security_policy.build(nil, 'test-nonce', %w[script-src])
      .split('; ')
      .to_h { |directive| [directive.split.first, directive.split.drop(1)] }
  end

  %w[connect-src img-src].each do |directive|
    it "allows regional GA4 and load-balanced Clarity collection in #{directive}" do
      expect(directives.fetch(directive)).to include(
        'https://*.google-analytics.com',
        'https://*.clarity.ms',
        'c.bing.com',
      )
    end

    it "does not allow unrestricted external collection in #{directive}" do
      expect(directives.fetch(directive)).not_to include('*', 'https:', 'http:')
    end
  end

  it 'keeps script loading restricted to existing hosts and a nonce' do
    expect(directives.fetch('script-src')).to include(
      "'nonce-test-nonce'",
      'www.googletagmanager.com',
      'www.clarity.ms',
      'scripts.clarity.ms',
    )
    expect(directives.fetch('script-src')).not_to include(
      "'unsafe-inline'",
      "'unsafe-eval'",
      'https://*.google-analytics.com',
      'https://*.clarity.ms',
    )
  end

  it 'retains the restrictive default policy' do
    expect(directives.fetch('default-src')).to eq(["'none'"])
  end
end
