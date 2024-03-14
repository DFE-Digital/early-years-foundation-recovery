require 'rails_helper'

RSpec.describe 'Summative assessment', type: :system do
  include_context 'with progress'
  include_context 'with user'

  let(:first_question_path) { '/modules/alpha/questionnaires/1-3-2-1' }

  before do
    view_pages_upto alpha, 'summative_questionnaire'
  end

  describe 'intro' do
    before do
      visit '/modules/alpha/content-pages/1-3-2'
    end

    it 'uses generic content' do
      expect(page).to have_content('End of module test')
        .and have_content('This end of module test is here to revisit what you have learned')
    end
  end

  context 'when a user has reached the assessment' do
    before do
      visit '/modules/alpha'
      click_on 'Resume module'
    end

    it 'can resume from the module overview page' do
      expect(page).to have_current_path(first_question_path, ignore_query: true)
    end
  end

  context 'when on a summative question page' do
    before do
      visit first_question_path
    end

    specify do
      expect(page).to have_link 'Back to Module 1 overview', href: '/modules/alpha'
    end

    context 'and no answer is selected' do
      before do
        click_on 'Save and continue'
      end

      it 'displays error message' do
        expect(page).to have_content 'Please select an answer'
      end
    end
  end

  describe 'results' do
    context 'when every question is answered correctly' do
      include_context 'with automated path'

      let(:fixture) do
        if Rails.application.migrated_answers?
          'spec/support/ast/alpha-pass-response.yml'
        else
          'spec/support/ast/alpha-pass.yml'
        end
      end

      before do
        visit '/modules/alpha/assessment-result/1-3-2-11'
      end

      it 'displays score with no wrong answers' do
        expect(page).to have_content 'You scored 100%'

        expect(page).to have_content('Congratulations')
          .and have_content('you have scored highly enough to receive a certificate of achievement for this module.')

        expect(page).not_to have_content 'Question One'
        expect(page).not_to have_content 'Question Two'
        expect(page).not_to have_content 'Question Three'
        expect(page).not_to have_content 'Question Four'
        expect(page).not_to have_content 'Question Five'
        expect(page).not_to have_content 'Question Six'
        expect(page).not_to have_content 'Question Seven'
        expect(page).not_to have_content 'Question Eight'
        expect(page).not_to have_content 'Question Nine'
        expect(page).not_to have_content 'Question Ten'
      end

      it 'links to the confidence check from module overview page' do
        visit '/modules/alpha'

        expect(page).to have_link 'Reflect on your learning'
      end

      it 'is not able to be retaken' do
        visit first_question_path

        expect(page).to have_selector '.govuk-checkboxes__input:disabled'
      end
    end

    context 'when failed' do
      include_context 'with automated path'

      let(:fixture) do
        if Rails.application.migrated_answers?
          'spec/support/ast/alpha-fail-response.yml'
        else
          'spec/support/ast/alpha-fail.yml'
        end
      end

      it 'displays score with wrong answers' do
        expect(page).to have_content 'You scored 0%'

        expect(page).to have_content('Revisit the module')
          .and have_content('Unfortunately you have not scored highly enough to receive a certificate.')

        # Lookup AST question labels
        expect(page).to have_content('Question One')
          .and have_content('Question Two')
          .and have_content('Question Three')
          .and have_content('Question Four')
          .and have_content('Question Five')
          .and have_content('Question Six')
          .and have_content('Question Seven')
          .and have_content('Question Eight')
          .and have_content('Question Nine')
          .and have_content('Question Ten')
      end

      it 'does not link to confidence check from the module overview page' do
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
  end
end
