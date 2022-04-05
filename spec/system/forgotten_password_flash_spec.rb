require 'rails_helper'

RSpec.describe 'Comfirmed user, following forgotten password process', type: :system do
  let(:user) { create :user, :confirmed }
  let(:token) { user.send_reset_password_instructions }

  context 'when resetting password' do
    it 'flash message displays correctly' do
      visit "/users/password/edit?reset_password_token=#{token}"
      fill_in 'New password', with: 'abc123'
      fill_in 'Confirm your password', with: 'abc123'
      click_on "Reset password"
      expect(page).to have_current_path("/")
      expect(page).to have_selector ".govuk-notification-banner--success"
      expect(page).to have_selector ".govuk-notification-banner__title", text: "Success"
      expect(page).to have_selector ".govuk-notification-banner__content", text: "Your password has been reset."
    end
  end
end
