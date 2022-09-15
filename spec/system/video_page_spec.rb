require 'rails_helper'

RSpec.describe 'Video page' do
  include_context 'with progress'
  include_context 'with user'

  before do
    visit '/modules/alpha/content-pages/1-2-1-2'
  end

  it 'renders the page header' do
    expect(page).to have_content('1-2-1-2')
  end

  it 'renders the page body' do
    expect(page).to have_content('In this video an early years expert explains')
  end

  it 'renders the video title' do
    expect(page).to have_content('Video: Vimeo Video Title')
  end

  it 'renders the embedded video' do
    expect(page).to have_selector('iframe')
  end

  it 'renders the transcript dropdown' do
    expect(page).to have_selector('.govuk-details__summary-text', text: 'Transcript')
  end

  it 'shows the transcript body after the dropdown has been clicked' do
    find('span', text: 'Transcript').click
    expect(page).to have_selector('.gem-c-govspeak', text: 'Through this activity the practitioner is looking to:', visible: :visible)
  end

  it 'collapses the transcript dropdown and hides the transcript body after being clicked twice' do
    2.times { find('span', text: 'Transcript').click }
    expect(page).not_to have_selector('.gem-c-govspeak', text: 'Through this activity the practitioner is looking to:', visible: :visible)
  end
end
