require 'rails_helper'

RSpec.describe 'Contentful configuration', :cms do
  subject(:config) { EarlyYearsFoundationRecovery::Application.config }

  before do
    skip 'CMS ONLY' unless Rails.application.cms?
  end

  it 'tests against CMS content' do
    expect(Rails.application).to be_cms
  end

  it 'tests against demo content' do
    expect(ContentfulRails.configuration.environment).to eq 'test'
    expect(config.contentful_environment).to eq 'test'
  end

  it 'tests against published content' do
    expect(Rails.application).not_to be_preview
  end

  it 'authenticates using credentials' do
    expect(config.contentful_space).to be_present
    expect(config.contentful_delivery_access_token).to be_present
    expect(config.contentful_preview_access_token).to be_present
    expect(config.contentful_management_access_token).not_to be_present # user specific
  end
end
