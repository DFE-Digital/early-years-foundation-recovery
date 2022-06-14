require 'rails_helper'

RSpec.describe 'User has locked account' do
  let(:user) { create :user, :confirmed }
  # returns unlock token
  let(:token) { user.lock_access! }
  
  context 'When the link in the email is clicked' do
    it 'Then it unlocks the account and shows the sign in page' do
      visit "/users/unlock?unlock_token=#{token}"

      # fill_in 'Email address', with: user.email
      # fill_in 'Password', with: 'StrongPassword123'
      # click_button 'Sign in'

      expect(page).to have_current_path('/users/sign_in')
        .and have_content('Your account has been unlocked successfully. Please sign in to continue')
      # expect(user.access_locked?).to eq false
    end
  end

  context 'When the link in the email is clicked a second time' do
    it 'Then an error message is displayed' do
      visit "/users/unlock?unlock_token=#{token}"
      visit "/users/unlock?unlock_token=#{token}"

      expect(page).to have_content('The link you followed has expired')
    end
  end
  
  context 'When a user waits for their account to be unlocked' do
    context 'And then locks their account again by entering the wrong password' do
      it 'Then an error message is displayed' do
        user.unlock_access!
        user.lock_access!
  
        visit "/users/unlock?unlock_token=#{token}"
  
        expect(page).to have_content('The link you followed has expired')
      end
    end
  end
end
