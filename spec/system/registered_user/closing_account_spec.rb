require 'rails_helper'

RSpec.describe 'Account deletion' do
  include_context 'with user'

  context 'when on my account page' do
    it 'has button to close account' do
      visit '/my-account'
      expect(page).to have_link 'Request to close account', href: '/my-account/close/edit-reason'
    end
  end

  context 'when on reason page' do
    before do
      visit '/my-account/close/edit-reason'
    end

    context 'and no radio button is selected' do
      before do
        click_on 'Continue'
      end

      it 'cannot progress to confirmation page' do
        expect(page).to have_content('There is a problem')
          .and have_content('Select a reason for closing your account')
      end
    end

    context 'and radio button is selected' do
      before do
        choose reason
        fill_in text_box, with: reason_other
        click_on 'Continue'
      end

      context 'and it is not "Another reason"' do
        let(:reason) { 'I did not find the training useful' }
        let(:text_box) { nil }
        let(:reason_other) { nil }

        it 'can progress to confirmation page' do
          expect(page).to have_current_path '/my-account/close/confirm'
        end
      end

      context 'and "Another reason" is selected' do
        let(:text_box) { 'Tell us why you want to close your account.' }
        let(:reason) { 'Another reason' }

        context 'and text box is not blank' do
          let(:reason_other) { 'Reason' }

          it 'can progress to confirmation page' do
            expect(page).to have_current_path '/my-account/close/confirm'
          end
        end

        context 'and text box is blank' do
          let(:reason_other) { nil }

          it 'can progress to confirmation page' do
            expect(page).to have_current_path '/my-account/close/confirm'
          end
        end
      end
    end
  end

  context 'when on confirmation page' do
    before do
      user.notes.create!(training_module: 'alpha', body: 'this is a note')
      user.responses.feedback.create!(
        training_module: 'course',
        question_name: 'feedback-textarea-only',
        question_type: 'feedback',
        text_input: 'this is feedback',
        correct: true,
      )

      visit '/my-account/close/confirm'
    end

    it 'has option to abort' do
      expect(page).to have_link 'Cancel and go back to my account', href: '/my-account'
    end

    context 'and account is closed' do
      before do
        click_on 'Close my account'
      end

      it 'is confirmed' do
        expect(page).to have_current_path '/my-account/close'
        expect(page).to have_text 'Account closed'
      end

      it 'redacts information' do
        user.reload
        expect(user.first_name).to eq 'Redacted'
        expect(user.last_name).to eq 'User'
        expect(user.email).to have_text 'redacted_user'
        expect(user.notes.count).to eq 0
        expect(user.responses.feedback.count).to eq 1
        expect(user.responses.feedback.first.text_input).to be_nil
        expect(user.valid_password?('RedactedUser12!@')).to eq true
      end
    end
  end
end
