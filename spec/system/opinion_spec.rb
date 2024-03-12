require 'rails_helper'

RSpec.describe 'End of module feedback form' do
  include_context 'with progress'
  include_context 'with user'

  let(:first_question_path) { '/modules/alpha/questionnaires/feedback-radiobutton' }
  let(:second_question_path) { '/modules/alpha/questionnaires/feedback-yesnoandtext' }

  it 'shows feedback question' do
    visit '/modules/alpha/content-pages/feedback-intro'
    expect(page).to have_content('Additional feedback')
    click_on 'Give feedback'
    expect(page).to have_content('Regarding the training module')
    expect(page).to have_content('Strongly agree')
  end

  it do
    visit second_question_path
    expect(page).to have_content('Did the module meet your expectations')
    expect(page).to have_content('Yes')
  end

  context 'when no answer is submitted' do
    it 'displays an error message' do
      visit first_question_path
      click_on 'Next'
      expect(page).to have_content 'Please select an answer'
    end
  end

  it 'does not link to additional feedback from the module overview page' do
    visit '/modules/alpha'

    expect(page).to have_content 'Reflect on your learning'
    expect(page).not_to have_link 'Additional feedback'
  end
end
