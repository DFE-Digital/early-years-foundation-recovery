require 'rails_helper'

RSpec.describe ContentPage, type: :model do
  let(:file) do
    Rails.root.join('config/locales/modules/test/test.yml')
  end

  let(:content) do
    YAML.load_file(file).dig('en', 'modules', 'test')
  end

  let(:content_page) do
    described_class.new(id: :basic, training_module: :test, type: :text_page)
  end

  describe '#heading' do
    it 'returns the heading data from the content file' do
      expect(content_page.heading).to eq content.dig(content_page.name.to_s, 'heading')
    end
  end

  describe '#body' do
    it 'returns the body data from the content file' do
      expect(content_page.body).to eq content.dig(content_page.name.to_s, 'body')
    end
  end
end
