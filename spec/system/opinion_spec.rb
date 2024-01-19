require 'rails_helper'

RSpec.describe 'End of module feedback form' do
  include_context 'with progress'
  include_context 'with user'

  it 'shows feedback question' do
    visit '/modules/alpha/content-pages/feedback-intro'
    expect(page).to have_content('Additional feedback')
    click_on 'Give feedback'
    expect(page).to have_content('Regarding the training module you have just completed: the content was easy to understand')
    expect(page).to have_content('Strongly agree')
  end

  it do
    visit '/modules/alpha/questionnaires/feedback3'
    expect(page).to have_content('Did the module meet your expectations')
    expect(page).to have_content('Yes')
  end

  context 'when no answer is submitted' do
    it 'displays an error message' do
      visit '/modules/alpha/questionnaires/feedback2'
      click_on 'Next'
      expect(page).to have_content 'Please select an answer'
    end
  end
end
