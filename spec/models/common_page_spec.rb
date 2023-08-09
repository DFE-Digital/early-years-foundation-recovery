require 'rails_helper'

RSpec.describe CommonPage, type: :model do
  subject(:common_page) do
    described_class.new(training_module: 'alpha', type: :confidence_intro, name: '1-3-3')
  end

  before do
    skip 'DEPRECATED' if Rails.application.cms?
  end

  it '#heading' do
    expect(common_page.heading).to eq 'Reflect on your learning'
  end

  it '#body' do
    expect(common_page.body).to include 'To help DfE to measure our impact'
  end
end
