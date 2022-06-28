require 'rails_helper'

RSpec.describe 'User following forgotten password process', type: :system do
  let(:user) { create :user, :confirmed }
  let(:token) { user.send_reset_password_instructions }
  let(:password) { 'ABCDE123xyh' }

  context 'when choosing a new password' do
    before do
      visit edit_user_password_path + "?reset_password_token=#{token}"
    end

    # Happy path scenario
    context 'and new password meets criteria' do
      let(:password) { 'NewPassword123' }

      it 'flash message displays correctly' do
        fill_in 'New password', with: password
        fill_in 'Confirm your password', with: password
        click_on 'Reset password'

        expect(page).to have_current_path(new_user_session_path)
          .and have_text('Success')
          .and have_text('Your password has been changed successfully.')
      end
    end

    # Unhappy path scenarios
    context 'and password is less than 10 characters' do
      let(:password) { 'Password' }

      it 'displays error message' do
        fill_in 'New password', with: password
        fill_in 'Confirm your password', with: password
        click_on 'Reset password'

        expect(page).to have_text('Password must be at least 10 characters.')
      end
    end

    context "and password and confirm password don't match" do
      let(:password) { 'NewPassword123' }
      let(:confirm_password) { 'NewPassword456' }

      it 'displays error message' do
        fill_in 'New password', with: password
        fill_in 'Confirm your password', with: confirm_password
        click_on 'Reset password'

        expect(page).to have_text("Sorry, your passwords don't match.")
      end
    end
  end

  context 'when entering valid email address' do
    it 'shows "Check email" page' do
      visit new_user_session_path
      click_link 'I have forgotten my password', visible: false

      expect(page).to have_text('I have forgotten my password')

      fill_in 'Email', with: user.email
      click_button 'Send email'

      expect(page).to have_text('Check your email')
    end
  end

  context 'when navigating to reset password page' do
    before do
      visit check_email_password_reset_user_path
    end

    it 'provides link to resend the email' do
      click_link 'Send me another email', visible: false

      expect(page).to have_current_path(new_user_password_path)
    end

    # to be changed when link is provided
    it 'provides link to contact us' do
      expect(page).to have_link 'contact us', href: Rails.application.credentials.contact_us, visible: :hidden
    end
  end

  context 'when navigating to the "Check email" page' do
    it 'provides back button to sign in page' do
      visit check_email_password_reset_user_path
      click_link 'Back'

      expect(page).to have_current_path(new_user_session_path)
    end
  end
end
