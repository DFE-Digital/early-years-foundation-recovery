require 'rails_helper'

RSpec.describe ContentPage, type: :model do
  subject(:content_page) do
    described_class.new(training_module: 'alpha', type: :text_page, name: '1-1-1')
  end

  it '#heading' do
    expect(content_page.heading).to eq '1-1-1'
  end

  it '#body' do
    expect(content_page.body).to include '## subheading'
  end

  it '#notes?' do
    expect(content_page).not_to be_notes
  end

  it '#page_numbers?' do
    expect(content_page).to be_page_numbers
  end
end
