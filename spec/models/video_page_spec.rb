require 'rails_helper'

RSpec.describe VideoPage, type: :model do
  let(:file) do
    Rails.root.join('config/locales/modules/alpha.yml')
  end

  let(:content) do
    YAML.load_file(file).dig('en', 'modules', 'alpha')
  end

  let(:video_page) do
    described_class.new(training_module: 'alpha', type: :video_page, name: '1-2-1-2')
  end

  describe '#heading' do
    it 'returns the heading data from the content file' do
      expect(video_page.heading).to eq(content.dig(video_page.name.to_s, 'heading'))
    end
  end

  describe '#body' do
    it 'returns the body data from the content file' do
      expect(video_page.body).to eq(content.dig(video_page.name.to_s, 'body'))
    end
  end

  describe '#video_id' do
    it 'returns the video id data from the content file' do
      expect(video_page.video_id).to eq(content.dig(video_page.name.to_s, 'video_id'))
    end
  end

  describe '#video_title' do
    it 'returns the video title data from the content file' do
      expect(video_page.video_title).to eq(content.dig(video_page.name.to_s, 'video_title'))
    end
  end

  describe '#video_provider' do
    it 'returns the video provider data from the content file' do
      expect(video_page.video_provider).to eq(content.dig(video_page.name.to_s, 'video_provider'))
    end
  end

  describe '#video_transcript' do
    it 'returns the video provider data from the content file' do
      expect(video_page.video_transcript).to eq(content.dig(video_page.name.to_s, 'video_transcript'))
    end
  end

  # describe '#youtube_url' do
  #   it 'returns the Youtube URL data from the content file' do
  #     expect(video_page.youtube_url).to eq(content.dig(video_page.name.to_s, 'youtube_url'))
  #   end

  #   it 'is valid' do
  #     expect(video_page).to be_valid
  #   end

  #   context 'when URL is not for an embedded YouTube video' do
  #     before { allow(video_page).to receive(:youtube_url).and_return('http://example.com') }

  #     it 'is invalid' do
  #       expect(video_page).to be_invalid
  #     end
  #   end
  # end
end
