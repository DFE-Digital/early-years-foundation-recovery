require 'rails_helper'

RSpec.describe VideoPage, type: :model do
  let(:file) { Rails.root.join('config/locales/modules/alpha.yml') }
  let(:content) { YAML.load_file(file).dig('en', 'modules', 'alpha') }
  let(:video_page) { described_class.new(training_module: 'alpha', type: :video_page, name: '1-2-1-2') }

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
      expect(video_page.video_id).to eq(content.dig(video_page.name.to_s, 'video', 'id'))
    end
  end

  describe '#video_title' do
    it 'returns the video title data from the content file' do
      expect(video_page.video_title).to eq(content.dig(video_page.name.to_s, 'video', 'title'))
    end
  end

  describe '#video_provider' do
    it 'returns the video provider data from the content file' do
      expect(video_page.video_provider).to eq(content.dig(video_page.name.to_s, 'video', 'provider'))
    end
  end

  describe '#video_transcript' do
    it 'returns the video provider data' do
      expect(video_page.transcript).to include("So let's look at an example of adult led learning.")
    end
  end

  describe '#vimeo_url' do
    it 'returns the url of the embedded vimeo video' do
      video_id = content.dig(video_page.name.to_s, 'video', 'id')
      expect(video_page.vimeo_url).to eq("https://player.vimeo.com/video/#{video_id}?enablejsapi=1&amp;origin=#{ENV['DOMAIN']}")
    end
  end

  describe '#youtube_url' do
    let(:file) { Rails.root.join('config/locales/modules/charlie.yml') }
    let(:content) { YAML.load_file(file).dig('en', 'modules', 'charlie') }
    let(:video_page) { described_class.new(training_module: 'charlie', type: :video_page, name: '1-1-3') }

    it 'returns the url of the embedded youtube video' do
      video_id = content.dig(video_page.name.to_s, 'video', 'id')
      expect(video_page.youtube_url).to eq("https://www.youtube.com/embed/#{video_id}?enablejsapi=1&amp;origin=#{ENV['DOMAIN']}")
    end
  end

  describe '#vimeo_video?' do
    it 'returns true if the provider is vimeo' do
      result = expect(video_page.video_provider).to eq(content.dig(video_page.name.to_s, 'video', 'provider'))
      expect(video_page.vimeo_video?).to eq result
    end
  end

  describe '#youtube_video?' do
    let(:file) { Rails.root.join('config/locales/modules/charlie.yml') }
    let(:content) { YAML.load_file(file).dig('en', 'modules', 'charlie') }
    let(:video_page) { described_class.new(training_module: 'charlie', type: :video_page, name: '1-1-3') }

    it 'returns true if the provider is youtube' do
      result = expect(video_page.video_provider).to eq(content.dig(video_page.name.to_s, 'video', 'provider'))
      expect(video_page.youtube_video?).to eq result
    end
  end
end
