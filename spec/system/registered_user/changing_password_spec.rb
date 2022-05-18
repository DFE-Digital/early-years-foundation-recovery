require 'rails_helper'

RSpec.describe 'Registered user changing password', type: :system do
  let(:user) { create :user, :registered, created_at: 1.month.ago }

  before do
    visit '/users/sign_in'
    fill_in 'Email address', with: user.email
    fill_in 'Password', with: 'StrongPassword123'
    click_button 'Sign in'
  end

  let(:today) { Date.today.to_formatted_s(:rfc822) } # 18 May 2022

  context 'when successful' do
    it 'updates password' do
      expect(page).to have_current_path '/'
      expect(page).to have_text('Signed in successfully')
        .and have_text('Child development training for early years providers')

      visit '/user/edit_password'
      fill_in 'Enter your current password', with: 'StrongPassword123'
      fill_in 'Create a new password', with: 'NewPasswordXYZ'
      fill_in 'Re-type your new password', with: 'NewPasswordXYZ'
      click_button 'Save'

      expect(page).to have_current_path '/user'
      expect(page).to have_text('Manage your account')      # page heading
        .and have_text('Your password has been reset')      # flash message
        .and have_text("Password last changed on #{today}") # event
    end
  end

  # context 'when unsuccessful' do
  # end

end
