require 'rails_helper'

RSpec.describe 'Confirmed user, following forgotten password process', type: :system do
  let(:user) { create :user, :confirmed }
  let(:token) { user.send_reset_password_instructions }
  let(:password) { 'ABC123xy' }

  context 'when resetting password' do
    it 'flash message displays correctly' do
      visit "/users/password/edit?reset_password_token=#{token}"
      fill_in 'New password', with: password
      fill_in 'Confirm your password', with: password
      click_on 'Reset password'

      expect(page).to have_text('Success')
        .and have_text('Your password has been reset.')
    end
  end
end
