# rubocop:disable RSpec/VerifiedDoubles

require 'rails_helper'

describe Training::Video, type: :model do
  let(:parent_module) { double('Training::Module', id: 'parent123', name: 'Parent Module') }

  describe '#parent' do
    it 'returns the parent module' do
      video = double('Training::Video', parent: parent_module)
      expect(video.parent).to eq parent_module
      expect(video.parent.name).to eq 'Parent Module'
    end
  end

  describe 'YouTube video fields' do
    let(:video) do
      double('Training::Video',
             video_id: 'XnP6jaK7ZAY',
             video_provider: 'youtube',
             title: 'Youtube Video Title',
             heading: 'Test Video Heading',
             page_type: 'video_page',
             transcript: "Today's subject is based on...",
             parent: parent_module,
             video_url: 'https://www.youtube.com/embed/XnP6jaK7ZAY?enablejsapi=1&amp;origin=recovery.app')
    end

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

  describe 'Vimeo video fields' do
    let(:video) do
      double('Training::Video',
             video_id: '743243040',
             video_provider: 'vimeo',
             title: 'Vimeo Video Title',
             heading: 'Test Video Heading',
             page_type: 'video_page',
             transcript: 'Vimeo transcript...',
             parent: parent_module,
             video_url: 'https://player.vimeo.com/video/743243040?enablejsapi=1&amp;origin=recovery.app')
    end

    it '#page_type' do
      expect(video.page_type).to eq 'video_page'
    end

    it '#video_id' do
      expect(video.video_id).to eq '743243040'
    end

    it '#video_provider' do
      expect(video.video_provider).to eq 'vimeo'
    end

    it '#video_url' do
      expect(video.video_url).to eq 'https://player.vimeo.com/video/743243040?enablejsapi=1&amp;origin=recovery.app'
    end

    it '#title' do
      expect(video.title).to eq 'Vimeo Video Title'
    end
  end
end
# rubocop:enable RSpec/VerifiedDoubles
