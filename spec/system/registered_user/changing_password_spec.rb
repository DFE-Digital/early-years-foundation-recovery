require 'rails_helper'

RSpec.describe 'Registered user changing password', type: :system do
  subject(:user) { create :user, :registered, created_at: 1.month.ago }

  include_context 'with registered user'

  before do
    visit '/my-account/edit-password'
    fill_in 'Enter your current password', with: 'StrongPassword123'
  end

  let(:today) { Time.zone.today.to_formatted_s(:rfc822) } # 18 May 2022

  context 'when successful' do
    it 'updates password' do
      fill_in 'Create a new password', with: 'NewPasswordXYZ'
      fill_in 'Re-type your new password', with: 'NewPasswordXYZ'
      click_button 'Save'

      expect(page).to have_current_path '/my-account'
      expect(page).to have_text('Manage your account')      # page heading
        .and have_text('Your password has been reset')      # flash message
        .and have_text("Password last changed on #{today}") # event
    end
  end

  context 'when too short' do
    it 'renders an error message' do
      fill_in 'Create a new password', with: 'short'
      fill_in 'Re-type your new password', with: 'short'
      click_button 'Save'

      expect(page).to have_text('Password is too short.')
        .and have_text('Your password must contain at least 6 characters, upper and lowercase letter, at least 1 number and special character')
    end
  end

  context 'when cancelled' do
    it 'returns to account page' do
      click_link 'Cancel'

      expect(page).to have_current_path '/my-account'
      expect(page).not_to have_text 'Your password has been reset'
    end
  end
end
