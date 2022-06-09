require 'rails_helper'

RSpec.describe 'User following forgotten password process', type: :system do
  let(:user) { create :user, :confirmed }
  let(:token) { user.send_reset_password_instructions }

  context 'when choosing a new password' do
    before do
      visit "/users/password/edit?reset_password_token=#{token}"
    end

    # Happy path scenario
    context 'and new password meets criteria' do
      let(:password) { 'NewPassword123' }

      it 'flash message displays correctly' do
        fill_in 'New password', with: password
        fill_in 'Confirm your password', with: password
        click_on 'Reset password'

        expect(page).to have_current_path('/users/sign_in')
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

        expect(page).to have_text("Confirmation doesn't match password.")
      end
    end
  end
end
