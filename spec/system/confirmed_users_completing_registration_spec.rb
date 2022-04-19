require 'rails_helper'

RSpec.describe 'Confirmed users completing registration' do
  before do
    visit '/users/sign_in'
    fill_in 'Email address', with: user.email
    fill_in 'Password', with: 'StrongPassword123'
    click_button 'Sign in'
  end

  let(:user) { create :user, :confirmed }

  context 'when I am a confirmed user' do
    it 'provides user to complete registration' do
      expect(page).to have_text('About you')

      fill_in 'First name', with: 'Jane'
      fill_in 'Surname', with: 'Doe'
      click_button 'Continue'

      expect(page).to have_text('About your setting')

      fill_in "Your setting's postcode", with: 'SE6 2TS'
      click_button 'Complete'

      expect(page).to have_text('Success')
        .and have_text('Thank you for creating an early years training account.')
    end

    it 'requires name and setting postcode to be complete' do
      click_button 'Continue'

      expect(page).to have_text('There is a problem')
        .and have_text('Enter a first name.')
        .and have_text('Enter a surname.')

      fill_in 'First name', with: 'Jane'
      fill_in 'Surname', with: 'Doe'
      click_button 'Continue'

      expect(page).to have_text('About your setting')
      click_button 'Complete'

      expect(page).to have_text('There is a problem')
        .and have_text("Enter your setting's postcode.")
    end
  end
end
