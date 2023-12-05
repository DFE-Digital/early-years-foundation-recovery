require 'rails_helper'

RSpec.describe 'Registered user changing password', type: :system do
  subject(:user) { create :user, :registered, created_at: 1.month.ago }

  let(:password) { 'Str0ngPa$$w0rd' }

  
  include_context 'with user'

  before do
    puts user.email
    visit '/my-account/edit-password'
    fill_in 'Enter your current password', with: 'Str0ngPa$$w0rd'
    fill_in 'Create a new password', with: password
    fill_in 'Confirm password', with: password
  end

  context 'when cancelled' do
    it 'returns to account page' do
      click_link 'Cancel'
      expect(page).to have_current_path '/my-account'
      expect(page).not_to have_text 'Your new password has been saved.'
    end
  end

  context 'when successful' do
    let(:password) { '12!@NewPassword' }
    let(:today) { Time.zone.today.to_formatted_s(:rfc822) } # 18 May 2022

    it 'updates password' do
      click_button 'Save'
      expect(page).to have_current_path '/my-account'
      expect(page).to have_text('Manage your account') # page heading
        .and have_text('Your new password has been saved.') # flash message
        .and have_text("Password last changed on #{today}") # event
    end
  end

  context 'when too short' do
    let(:password) { 'short' }

    it 'renders an error message' do
      click_button 'Save'
      expect(page).to have_text 'Password must be at least 10 characters.'
    end
  end

  context 'when blank' do
    let(:password) { '' }

    it 'renders an error message' do
      click_button 'Save'
      expect(page).to have_text 'Enter a password.'
    end
  end
end
