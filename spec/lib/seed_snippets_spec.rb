require 'rails_helper'
require 'seed_snippets'

RSpec.describe SeedSnippets do
  subject(:locales) { described_class.new.call }

  it 'converts all translations' do
    expect(locales.count).to be 224
  end

  it 'dot separated key -> Page::Resource#name' do
    expect(locales.first[:name]).to eq 'user.show.your_setting_details_html'
  end

  it 'value -> Page::Resource#body' do
    expect(locales.first[:body]).to eq "<h2 class='govuk-heading-m'>Your setting details</h2>"
  end
end
