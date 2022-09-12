require 'rails_helper'

RSpec.describe 'Confidence check' do
  include_context 'with progress'
  include_context 'with user'

  let(:video_page_path) { '/modules/alpha/content-pages/1-2-1-2' }

  context 'when video page is visited' do
    it 'it renders a video and transcript' do
      visit video_page_path
      expect(page).to have_current_path(video_page_path, ignore_query: true)
    end
  end
end
