require 'rails_helper'

RSpec.describe YoutubePage, type: :model do
  let(:file) do
    Rails.root.join('config/locales/modules/test/test.yml')
  end

  let(:content) do
    YAML.load_file(file).dig('en', 'modules', 'test')
  end

  let(:youtube_page) do
    described_class.new(name: :video, training_module: :test, type: :youtube_page)
  end

  describe '#heading' do
    it 'returns the heading data from the content file' do
      expect(youtube_page.heading).to eq(content.dig(youtube_page.name.to_s, 'heading'))
    end
  end

  describe '#body' do
    it 'returns the body data from the content file' do
      expect(youtube_page.body).to eq(content.dig(youtube_page.name.to_s, 'body'))
    end
  end

  describe '#video_title' do
    it 'returns the video title data from the content file' do
      expect(youtube_page.video_title).to eq(content.dig(youtube_page.name.to_s, 'video_title'))
    end
  end

  describe '#youtube_url' do
    it 'returns the Youtube URL data from the content file' do
      expect(youtube_page.youtube_url).to eq(content.dig(youtube_page.name.to_s, 'youtube_url'))
    end

    it 'is valid' do
      expect(youtube_page).to be_valid
    end

    context 'when URL is not for an embedded YouTube video' do
      before { allow(youtube_page).to receive(:youtube_url).and_return('http://example.com') }

      it 'is invalid' do
        expect(youtube_page).to be_invalid
      end
    end
  end
end
