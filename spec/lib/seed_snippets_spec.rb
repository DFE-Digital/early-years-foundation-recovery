require 'rails_helper'
require 'seed_snippets'

RSpec.describe SeedSnippets do
  subject(:locales) { described_class.new.call }

  it 'converts all translations' do
    expect(locales.count).to be 171
  end

  it 'dot separated key -> Page::Resource#name' do
    expect(locales.first[:name]).to eq 'activemodel.errors.models.user.attributes.current_password.blank'
  end

  it 'value -> Page::Resource#body' do
    expect(locales.first[:body]).to eq 'Enter your current password.'
  end
end
