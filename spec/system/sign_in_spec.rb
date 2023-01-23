require 'rails_helper'

RSpec.describe 'Sign in' do
  let(:email_address) { user.email }
  let(:password) { 'StrongPassword123' }

  before do
    visit '/users/sign-in'
    fill_in 'Email address', with: email_address
    fill_in 'Password', with: password
    click_button 'Sign in'
  end

  context 'when user is registered' do
    let(:user) { create :user, :registered }

    context 'and enters valid credentials' do
      it 'signs in successfully' do
        expect(page).to have_text('My modules')
        expect(page).not_to have_text('Signed in successfully')
      end
    end

    context 'and enters incorrect email' do
      let(:email_address) { 'user@incorrect.com' }

      it 'displays a warning' do
        expect(page).to have_text('Warning')
          .and have_text('Enter a valid email address and password. Your account will be locked after 5 unsuccessful attempts. We will email you instructions to unlock your account.')
      end
    end

    context 'and enters incorrect password' do
      let(:password) { 'IncorrectPassword' }

      it 'displays a warning' do
        expect(page).to have_text('Warning')
          .and have_text('Enter a valid email address and password. Your account will be locked after 5 unsuccessful attempts. We will email you instructions to unlock your account.')
      end
    end
  end

  context 'when user is confirmed' do
    let(:user) { create :user, :confirmed }

    context 'and enters valid credentials' do
      it 'signs in successfully' do
        expect(page).to have_text('About you') # extra registration
      end
    end

    context 'and makes 5 incorrect password attempts' do
      let(:password) { 'IncorrectPassword' }

      4.times do # 4 additional times, 5 in total
        before do
          fill_in 'Email address', with: email_address
          fill_in 'Password', with: password
          click_button 'Sign in'
        end
      end

      it 'locks account', :vcr do
        user.reload
        expect(user.failed_attempts).to eq 5
        expect(user.access_locked?).to be true
        expect(page).to have_text('Warning')
          .and have_text('Enter a valid email address and password. Your account will be locked after 5 unsuccessful attempts. We will email you instructions to unlock your account.')
      end
    end
  end
end
