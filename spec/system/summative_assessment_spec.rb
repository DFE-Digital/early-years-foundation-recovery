require 'rails_helper'

RSpec.describe 'Summative assessment' do
  include_context 'with progress'
  include_context 'with user'

  let(:first_question_path) { '/modules/alpha/questionnaires/1-3-2-1' }

  before do
    skip 'WIP' if Rails.application.cms?
    start_summative_assessment(alpha)
  end

  describe 'intro' do
    it 'uses generic content' do
      visit '/modules/alpha/content-pages/1-3-2'
      expect(page).to have_content('End of module test')
        .and have_content('This end of module test is here to revisit what you have learned')
    end
  end

  context 'when a user has reached the assessment' do
    it 'can resume from the module overview page' do
      visit '/modules/alpha'
      click_on 'Resume module'
      expect(page).to have_current_path(first_question_path, ignore_query: true)
    end
  end

  context 'with all questions answered correctly' do
    before do
      visit first_question_path

      # # TODO: extract to `with_progress`
      # correct_options.each.with_index(1) do |options, position|
      #   options.each do |option|
      #     options.one? ? choose(option) : check(option)
      #   end

      #   if position.eql?(10)
      #     click_on 'Finish test'
      #   else
      #     click_on 'Save and continue'
      #   end
      # end

      take_assessment(correct: 10)
    end

    it 'displays the correct score as a percentage' do
      expect(page).to have_content 'You scored 100%'
    end

    it 'tells them they have passed' do
      expect(page).to have_content('Congratulations')
        .and have_content('you have scored highly enough to receive a certificate of achievement for this module.')
    end

    it 'displays no incorrect answers' do
      skip 'update with new demo content'
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
      expect(page).not_to have_link 'Retake test'

      visit first_question_path

      expect(page).to have_selector '.govuk-checkboxes__input:disabled'
    end
  end

  context 'when the threshold is passed' do
    before do
      visit first_question_path
      take_assessment(correct: 7)
    end

    it 'displays the score as a whole number percentage' do
      expect(page).to have_content 'You scored 70%'
    end

    it 'tells them they have passed' do
      expect(page).to have_content('Congratulations')
        .and have_content('you have scored highly enough to receive a certificate of achievement for this module.')
    end

    it 'displays only incorrect answers' do
      skip 'update with new demo content'
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
      take_assessment(correct: 0)
    end

    it 'displays the correct score as a percentage' do
      expect(page).to have_content 'You scored 0%'
    end

    it 'tells them they have failed' do
      expect(page).to have_content('Revisit the module')
        .and have_content('Unfortunately you have not scored highly enough to receive a certificate.')
    end

    it 'displays only incorrect answers' do
      skip 'update with new demo content'
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
      click_on 'Retake test'
      click_on 'Start test'

      expect(page).not_to have_selector '.govuk-checkboxes__input:disabled'
    end

    it 'links back to content' do
      expect(page).to have_link 'revisit topic'
    end
  end

  context 'when on a question page' do
    specify do
      visit first_question_path
      expect(page).to have_link 'Back to Module 1 overview', href: '/modules/alpha'
    end
  end

  context 'when no answer is selected' do
    it 'displays error message' do
      visit first_question_path
      click_on 'Save and continue'
      expect(page).to have_content 'Please select an answer'
    end
  end
end
