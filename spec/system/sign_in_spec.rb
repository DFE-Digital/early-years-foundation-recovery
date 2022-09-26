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
        .and have_text('Enter a valid email address and password. Your account will be locked after 5 unsuccessful attempts. We will email you instructions to unlock your account.')

      fill_in 'Email address', with: user.email
      fill_in 'Password', with: 'incorrectpassword'
      click_button 'Sign in'

      expect(page).to have_text('Warning')
        .and have_text('Enter a valid email address and password. Your account will be locked after 5 unsuccessful attempts. We will email you instructions to unlock your account.')
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
        .and have_text('Enter a valid email address and password. Your account will be locked after 5 unsuccessful attempts. We will email you instructions to unlock your account.')
    end
  end

  context "when what's new page has not been viewed" do
    let(:user) { create :user, :completed, :display_whats_new }

    it "visits what's new page after sign in" do
      fill_in 'Email address', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Sign in'

      expect(page).to have_current_path('/whats_new')
    end
  end
  
  context "when what's new page has been viewed" do
    let(:user) { create :user, :completed, :dont_display_whats_new }
    
    it "does not visit what's new page after sign in" do
      fill_in 'Email address', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Sign in'

      expect(page).not_to have_current_path('/whats_new')
    end
  end


end
