require 'rails_helper'

RSpec.describe 'Summative assessment' do
  include_context 'with progress'

  before do
    view_pages_before_summative_assessment(alpha)
  end

  include_context 'with user'

  context 'when a user has visited each module up to and including a summative assessment' do
    it 'can click to resume training to visit the summative assessment page' do
      visit '/modules/alpha'
      click_on 'Resume training'
      expect(page).to have_current_path '/modules/alpha/summative-assessments/1-3-2-1', ignore_query: true
    end
  end

  context 'when a user has passed the summative assessment with a score of 100%' do
    before do
      visit '/modules/alpha/summative-assessments/1-3-2-1'
      3.times do
        check 'Correct answer 1'
        check 'Correct answer 2'
        click_on 'Save and continue'
      end
      choose 'Correct answer 1'
      click_on 'Finish test'
    end

    it 'displays the correct score' do
      expect(page).to have_content 'You scored 100%'
    end

    it 'displays message telling the user they have passed the summative assessment' do
      expect(page).to have_content('Congratulations')
        .and have_content('Congratulations - you have scored highly enough to receive a certificate of achievement for this module.')
    end

    it 'can navigate to confidence check from module overview page' do
      visit '/modules/alpha'

      expect(page).to have_link('Reflect on your learning')
    end

    it 'is not able to retake the assessment' do
      visit '/modules/alpha/summative-assessments/1-3-2-1'

      expect(page).to have_selector('.govuk-checkboxes__input:disabled')
    end
  end

  context 'when a user has passed the summative assessment with a score of 75%' do
    before do
      visit '/modules/alpha/summative-assessments/1-3-2-1'
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

    it 'displays the correct score' do
      expect(page).to have_content 'You scored 75%'
    end

    it 'displays message telling the user they have passed the summative assessment' do
      expect(page).to have_content('Congratulations')
        .and have_content('Congratulations - you have scored highly enough to receive a certificate of achievement for this module.')
    end
  end

  context 'when a user has failed the summative assessment' do
    # Fail the summative assessment
    before do
      visit '/modules/alpha/summative-assessments/1-3-2-1'
      3.times do
        check 'Wrong answer 1'
        check 'Wrong answer 2'
        click_on 'Save and continue'
      end
      choose 'Wrong answer 1'
      click_on 'Finish test'
    end

    it 'displays the correct score' do
      expect(page).to have_content 'You scored 0%'
    end

    it 'displays message telling the user they have failed the summative assessment' do
      expect(page).to have_content('Revisit the module')
        .and have_content('Unfortunately you have not scored highly enough to receive a certificate.')
    end

    it 'displays the incorrect answers' do
      expect(page).to have_content('Question One')
        .and have_content('Question Two')
        .and have_content('Question Three')
        .and have_content('Question Four')
    end

    it 'cannot navigate to confidence check from module overview page' do
      visit '/modules/alpha'

      expect(page).to have_content('Reflect on your learning')
      expect(page).not_to have_link('Reflect on your learning')
    end

    it 'is able to retake the assessment' do
      visit '/modules/alpha/summative-assessments/1-3-2-1'

      expect(page).to have_selector('.govuk-checkboxes__input')
    end
  end
end
