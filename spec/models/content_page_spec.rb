require 'rails_helper'

RSpec.describe ContentPage, type: :model do
  let(:content) { YAML.load_file(Rails.root.join('config/locales/modules.yml')).dig('en', 'modules', 'test') }
  let(:content_page) { described_class.new(id: :basic, training_module: :test, type: :text_page) }

  describe '#heading' do
    it 'returns the heading data from the content file' do
      expect(content_page.heading).to eq(content.dig(content_page.name.to_s, 'heading'))
    end
  end

  describe '#body' do
    it 'returns the body data from the content file' do
      expect(content_page.body).to eq(content.dig(content_page.name.to_s, 'body'))
    end
  end
end
