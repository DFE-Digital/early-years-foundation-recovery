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

  describe '#debug_summary' do
    it 'summarises information' do
      expect(video.debug_summary).to eq(
        <<~SUMMARY,
          uid: LaZ22OwFuaFuXRjVvNLwy
          module uid: 4u49zTRJzYAWsBI6CitwN4
          module name: bravo
          published at: Management Key Missing
          page type: video_page

          ---
          previous: 1-2-1-1
          current: 1-2-1-2
          next: 1-2-1-3

          ---
          submodule: 2
          topic: 1

          ---
          position in module: 9th
          position in submodule: 4th
          position in topic: 3rd

          ---
          pages in submodule: 4
          pages in topic: 4
        SUMMARY
      )
    end
  end
end
