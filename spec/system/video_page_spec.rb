require 'rails_helper'

RSpec.describe 'Video page' do
  include_context 'with progress'
  include_context 'with user'
  

  before do
    visit '/modules/alpha/content-pages/1-2-1-2'
  end

  it 'it renders the page header' do
    expect(page).to have_content('Video Page Heading')
  end

  it 'it renders the page body' do
    expect(page).to have_content('In this video an early years expert explains')
  end

  it 'it renders the video title' do
    expect(page).to have_content('Video: Vimeo Video Title')
  end

  # expect a vimeo embed link and iframe?
  it 'it renders the embedded video' do
    expect(page).to have_selector('iframe')
  end

  it 'it renders the transcript dropdown' do
    expect(page).to have_selector('.govuk-details__summary-text', text: 'Transcript')
  end

  it 'it shows the transcript body after the dropdown has been clicked' do
    find('span', text: 'Transcript').click
    expect(page).to have_selector('.gem-c-govspeak', text: 'Through this activity the practitioner is looking to:', visible: true)
  end

  it 'the transcript dropdown collapses after being clicked twice' do
    2.times { find('span', text: 'Transcript').click }
    expect(page).not_to have_selector('.gem-c-govspeak', text: 'Through this activity the practitioner is looking to:', visible: true)
  end

end
