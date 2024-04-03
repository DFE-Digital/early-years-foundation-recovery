require 'rails_helper'

RSpec.describe 'End of module feedback form' do
  include_context 'with progress'
  include_context 'with user'

  let(:first_question_path) { '/modules/alpha/questionnaires/feedback-radiobutton' }
  let(:second_question_path) { '/modules/alpha/questionnaires/feedback-yesnoandtext' }
  let(:intro_path) { '/modules/alpha/content-pages/feedback-intro' }

  it 'shows feedback question' do
    visit intro_path
    expect(page).to have_content('Additional feedback')
    click_on 'Give feedback'
    expect(page).to have_content('Feedback question 1 - Select from following')
    expect(page).to have_content('Strongly agree')
  end

  it do
    visit second_question_path
    expect(page).to have_content('Feedback question 2 - Select from following')
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

  describe 'skippable questions' do
    context 'when not skipped' do
      it 'pagination shows all pages' do
        visit first_question_path
        expect(page).to have_content 'Page 1 of 8'
      end
    end

    context 'when skipped' do
      before do
        create :response,
               question_name: 'feedback-oneoffquestion',
               training_module: 'alpha',
               answers: [1],
               correct: true,
               user: user,
               question_type: 'feedback'
      end

      it 'pagination does not show skipped pages' do
        visit first_question_path
        expect(page).to have_content 'Page 1 of 7'
      end
    end
  end
end
