require 'rails_helper'

RSpec.describe VideoPage, type: :model do
  subject(:video_page) do
    described_class.new(training_module: mod_name, type: :video_page, name: page_name)
  end

  before do
    skip 'DEPRECATED' if Rails.application.cms?
  end

  let(:mod_name) { 'alpha' }
  let(:page_name) { '1-2-1-2' }

  it '#heading' do
    expect(video_page.heading).to eq '1-2-1-2'
  end

  it '#body' do
    expect(video_page.body).to include 'In this video an early years expert explains'
  end

  it '#video_title' do
    expect(video_page.video_title).to eq 'Vimeo Video Title'
  end

  it '#video_transcript' do
    expect(video_page.transcript).to include 'The children have gone outside and started a bug hunt.'
  end

  describe '#video_url' do
    context 'when vimeo' do
      it 'sources from vimeo' do
        expect(video_page.video_url).to eq 'https://player.vimeo.com/video/743243040?enablejsapi=1&amp;origin=recovery.app'
      end
    end

    context 'when youtube' do
      let(:page_name) { '1-1-3' }
      let(:mod_name) { 'charlie' }

      it 'sources from youtube' do
        expect(video_page.video_url).to eq 'https://www.youtube.com/embed/XnP6jaK7ZAY?enablejsapi=1&amp;origin=recovery.app'
      end
    end
  end
end
