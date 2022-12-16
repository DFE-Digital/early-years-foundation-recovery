require 'rails_helper'

RSpec.describe 'Account deletion' do
  include_context 'with user'

  context 'when on my account page' do
    it 'has button to close account' do
      visit '/my-account'
      expect(page).to have_link 'Request to close account', href: '/my-account/account-deletion/edit'
    end
  end

  context 'when on enter password screen' do
    before do
      visit '/my-account/account-deletion/edit'
      fill_in 'For security, enter your password', with: password
      click_on 'Continue'
    end

    context 'and correct password is entered' do
      let(:password) { user.password }

      it 'can progress to reason page' do
        expect(page).to have_current_path '/my-account/account-deletion/edit-reason'
      end
    end

    context 'and incorrect password is entered' do
      let(:password) { 'IncorrectPassword' }

      it 'can progress to reason page' do
        expect(page).to have_content('There is a problem')
          .and have_content('Enter a valid password')
      end
    end
  end

  context 'when on reason page' do
    before do
      visit '/my-account/account-deletion/edit-reason'
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
          expect(page).to have_current_path '/my-account/account-deletion/confirm-delete-account'
        end
      end

      context 'and "Another reason" is selected' do
        let(:text_box) { 'Tell us why you want to close your account.' }
        let(:reason) { 'Another reason' }

        context 'and text box is not blank' do
          let(:reason_other) { 'Reason' }

          it 'can progress to confirmation page' do
            expect(page).to have_current_path '/my-account/account-deletion/confirm-delete-account'
          end
        end

        context 'and text box is blank' do
          let(:reason_other) { nil }

          it 'cannot progress to confirmation page' do
            expect(page).to have_content('There is a problem')
              .and have_content('Enter a reason why you want to close your account')
          end
        end
      end
    end
  end

  context 'when on confirmation page' do
    let!(:note) { create(:note) }

    before do
      user.notes.push(note)
      user.save!
      visit '/my-account/account-deletion/confirm-delete-account'
    end

    it 'has option to abort' do
      expect(page).to have_link 'Cancel and go back to my account', href: '/my-account'
    end

    context 'and account is closed' do
      before do
        click_on 'Close my account'
      end

      it 'redirects to account closed page' do
        expect(page).to have_text 'Account closed'
      end

      it 'redacts information' do
        user.reload
        expect(user.first_name).to eq 'Redacted'
        expect(user.last_name).to eq 'User'
        expect(user.email).to have_text 'redacted_user'
        expect(user.notes.first.body).to eq nil
        expect(user.valid_password?('redacteduser')).to eq true
      end
    end
  end
end
