require 'rails_helper'

RSpec.describe 'Sign in', type: :system do
  before do
    visit '/users/sign-in'
  end

  context 'when user is registered' do
    let(:user) { create :user, :registered }

    it 'is successful with valid credentials' do
      fill_in 'Email address', with: user.email
      fill_in 'Password', with: 'StrongPassword123'
      click_button 'Sign in'

      expect(page).to have_text('Signed in successfully')
    end

    it 'warns when credentials are invalid' do
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
  end

  context 'when user is confirmed' do
    let(:user) { create :user, :confirmed }

    it 'signs in successfully with valid credentials' do
      fill_in 'Email address', with: user.email
      fill_in 'Password', with: 'StrongPassword123'
      click_button 'Sign in'

      expect(page).to have_text('Signed in successfully')
        .and have_text('About you') # extra registration
    end

    it 'locks account after 6 incorrect password attempts' do
      6.times do
        fill_in 'Email address', with: user.email
        fill_in 'Password', with: 'IncorrectPassword'
        click_button 'Sign in'
      end

      user.reload

      expect(user.failed_attempts).to eq 6
      expect(user.access_locked?).to be true

      expect(page).to have_text('Warning')
        .and have_text('Please ensure you have entered your valid email address and password.')
      # .and have_text('For security reasons your account has been locked for 2 hours. For faster access we have sent you an email to reset your password.')
    end
  end
end
