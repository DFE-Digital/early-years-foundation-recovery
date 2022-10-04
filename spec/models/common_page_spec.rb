require 'rails_helper'

RSpec.describe CommonPage, type: :model do
  let(:file) do
    Rails.root.join('config/locales/en.yml')
  end

  let(:content) do
    YAML.load_file(file).dig('en', 'confidence_intro')
  end

  let(:content_page) do
    described_class.new(training_module: 'alpha', type: :confidence_intro, id: '1-3-3', name: '1-3-3')
  end

  describe '#heading' do
    it 'returns the heading data from the content file' do
      expect(content_page.heading).to eq content['heading']
    end
  end

  describe '#body' do
    it 'returns the body data from the content file' do
      expect(content_page.body).to eq content['body']
    end
  end
end
