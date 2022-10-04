require 'rails_helper'

RSpec.describe ContentPage, type: :model do
  let(:file) do
    Rails.root.join('config/locales/modules/alpha.yml')
  end

  let(:content) do
    YAML.load_file(file).dig('en', 'modules', 'alpha')
  end

  let(:content_page) do
    described_class.new(training_module: 'alpha', type: :text_page, id: '1-1-1', name: '1-1-1')
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

  # describe '#image' do
  # end

  # describe '#module_item' do
  # end

  # describe '#formative?' do
  # end
end
