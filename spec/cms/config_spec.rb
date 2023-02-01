require 'rails_helper'

RSpec.describe 'Contentful configuration', :cms do
  before do
    skip 'WIP' unless Rails.application.cms?
  end

  it 'tests against demo content' do
    expect(ContentfulRails.configuration.environment).to eq 'test'
    expect(EarlyYearsFoundationRecovery::Application.config.contentful_environment).to eq 'test'
  end
end
