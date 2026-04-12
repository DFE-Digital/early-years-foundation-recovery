# frozen_string_literal: true

# spec/support/contentful_stub_service.rb
# Stubs Contentful API for tests that require preview=false

RSpec.shared_context 'when stub contentful for published tests' do
  before do
    # Only stub if ENV is set to true (for targeted tests)
    if ENV['CONTENTFUL_PREVIEW'] == 'true'
      allow(ContentfulModel).to receive(:use_preview_api).and_return(false)
      allow(ContentfulRails.configuration).to receive(:enable_preview_domain).and_return(false)
    end
  end
end
