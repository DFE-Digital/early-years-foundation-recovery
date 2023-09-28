require 'rails_helper'

describe Training::Video, type: :model do
  subject(:video) do
    # NB: query class is only possible with a page name that is unique
    described_class.find_by(name: '1-2-1-2').first
  end

  describe '#parent' do
    it 'returns the parent module' do
      expect(video.parent).to be_a Training::Module
      expect(video.parent.name).to eq 'bravo'
    end
  end

  describe 'CMS fields' do
    it '#page_type' do
      expect(video.page_type).to eq 'video_page'
    end

    it '#video_id' do
      expect(video.video_id).to eq 'XnP6jaK7ZAY'
    end

    it '#video_provider' do
      expect(video.video_provider).to eq 'youtube'
    end

    it '#video_url' do
      expect(video.video_url).to eq 'https://www.youtube.com/embed/XnP6jaK7ZAY?enablejsapi=1&amp;origin=recovery.app'
    end

    it '#title' do
      expect(video.title).to eq 'Youtube Video Title'
    end

    it '#transcript' do
      expect(video.transcript).to start_with "Today's subject is based on"
    end
  end
end
