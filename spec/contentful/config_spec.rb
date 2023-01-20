require 'rails_helper'

RSpec.describe 'Contentful configuration', cms: true do

  it 'tests against demo content' do
    expect(ContentfulRails.configuration.environment).to eq 'test'
    expect(EarlyYearsFoundationRecovery::Application.config.contentful_environment).to eq 'test'
  end
end
