require 'rails_helper'

RSpec.describe 'Summative questionnaire' do
  include_context 'with progress'
  include_context 'with user'

  let(:first_question_path) { '/modules/alpha/questionnaires/1-3-2-1' }

  before do
    start_summative_assessment(alpha)
  end

  describe 'intro' do
    it 'uses generic content' do
      visit '/modules/alpha/content-pages/1-3-2'
      expect(page).to have_content 'End of module test'
    end
  end

  context 'when a user has reached the assessment' do
    it 'can resume from the module overview page' do
      visit '/modules/alpha'
      click_on 'Resume training'
      expect(page).to have_current_path(first_question_path, ignore_query: true)
    end
  end

  context 'when every question answered correctly' do
    before do
      visit first_question_path
      3.times do
        check 'Correct answer 1'
        check 'Correct answer 2'
        click_on 'Save and continue'
      end
      choose 'Correct answer 1'
      click_on 'Finish test'
    end

    it 'displays the correct score as a percentage' do
      expect(page).to have_content 'You scored 100%'
    end

    it 'tells them they have passed' do
      expect(page).to have_content('Congratulations')
        .and have_content('you have scored highly enough to receive a certificate of achievement for this module.')
    end

    it 'displays no incorrect answers' do
      expect(page).not_to have_content 'Question One'
      expect(page).not_to have_content 'Question Two'
      expect(page).not_to have_content 'Question Three'
      expect(page).not_to have_content 'Question Four'
    end

    it 'allows navigating to the confidence check from module overview page' do
      visit '/modules/alpha'

      expect(page).to have_link 'Reflect on your learning'
    end

    it 'is not able to be retaken' do
      visit first_question_path

      expect(page).to have_selector '.govuk-checkboxes__input:disabled'
    end
  end

  context 'when the threshold is passed' do
    before do
      visit first_question_path
      2.times do
        check 'Correct answer 1'
        check 'Correct answer 2'
        click_on 'Save and continue'
      end
      check 'Wrong answer 1'
      check 'Wrong answer 2'
      click_on 'Save and continue'

      choose 'Correct answer 1'
      click_on 'Finish test'
    end

    it 'displays the score as a whole number percentage' do
      expect(page).to have_content 'You scored 75%'
    end

    it 'tells them they have passed' do
      expect(page).to have_content('Congratulations')
        .and have_content('you have scored highly enough to receive a certificate of achievement for this module.')
    end

    it 'displays only incorrect answers' do
      expect(page).to have_content 'Question Three'

      expect(page).not_to have_content 'Question One'
      expect(page).not_to have_content 'Question Two'
      expect(page).not_to have_content 'Question Four'
    end

    it 'is not able to be retaken' do
      visit first_question_path

      expect(page).to have_selector '.govuk-checkboxes__input:disabled'
    end
  end

  context 'when failed' do
    before do
      visit first_question_path
      3.times do
        check 'Wrong answer 1'
        check 'Wrong answer 2'
        click_on 'Save and continue'
      end
      choose 'Wrong answer 1'
      click_on 'Finish test'
    end

    it 'displays the correct score as a percentage' do
      expect(page).to have_content 'You scored 0%'
    end

    it 'tells them they have failed' do
      expect(page).to have_content('Revisit the module')
        .and have_content('Unfortunately you have not scored highly enough to receive a certificate.')
    end

    it 'displays only incorrect answers' do
      expect(page).to have_content('Question One')
        .and have_content('Question Two')
        .and have_content('Question Three')
        .and have_content('Question Four')
    end

    it 'prevents navigating to confidence check from the module overview page' do
      visit '/modules/alpha'

      expect(page).to have_content 'Reflect on your learning'
      expect(page).not_to have_link 'Reflect on your learning'
    end

    it 'can be retaken' do
      visit first_question_path

      expect(page).to have_selector '.govuk-checkboxes__input'
    end
  end
end
