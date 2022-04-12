require 'rails_helper'

RSpec.describe 'Users sign in', type: :system do
  before do
    driven_by(:rack_test)
    visit '/users/sign_in'
  end

  context 'when I am a registered user' do
    let(:user) { create :user, :registered }

    it 'signs in successfully with valid credentials' do
      fill_in 'Email address', with: user.email
      fill_in 'Password', with: 'StrongPassword123'
      click_button 'Sign in'

      expect(page).to have_text('Signed in successfully')
        .and have_text('Your application is ready') # home page
    end

    it 'warns when invalid email or password' do
      fill_in 'Email address', with: 'user@incorrect.com'
      fill_in 'Password', with: 'StrongPassword123'
      click_button 'Sign in'

      expect(page).to have_text('Warning')
        .and have_text('Please ensure you have entered your valid email address and password.')

      fill_in 'Email address', with: user.email
      fill_in 'Password', with: 'incorrectpassword'
      click_button 'Sign in'

      expect(page).to have_text('Warning')
        .and have_text('Please ensure you have entered your valid email address and password.')
    end

    it 'provides link when i forgot my password' do
      click_link 'I have forgotten my password', visible: false

      expect(page).to have_text('I have forgotten my password')

      fill_in 'Email', with: user.email
      click_button 'Send email'

      expect(page).to have_text('Check your email')
    end
  end

  context 'when I am a confirmed user' do
    let(:user) { create :user, :confirmed }

    it 'signs in successfully with valid credentials' do
      fill_in 'Email address', with: user.email
      fill_in 'Password', with: 'StrongPassword123'
      click_button 'Sign in'

      expect(page).to have_text('Signed in successfully')
        .and have_text('About you') # extra registration
    end
  end
end
