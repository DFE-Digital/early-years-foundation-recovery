require 'rails_helper'

RSpec.describe 'User has locked account' do
  let(:user) { create :user, :confirmed }
  let!(:token) { user.lock_access! }

  context 'when the link in the email is clicked' do
    it 'then it unlocks the account and shows the sign in page' do
      visit user_unlock_path + "?unlock_token=#{token}"

      expect(page).to have_current_path(new_user_session_path)
        .and have_content('Your account has been unlocked successfully. Please sign in to continue')
    end
  end

  context 'when the link in the email is clicked a second time' do
    it 'then an error message is displayed' do
      visit user_unlock_path + "?unlock_token=#{token}"
      visit user_unlock_path + "?unlock_token=#{token}"

      expect(page).to have_content('The link you followed has expired')
    end
  end

  context 'when a user waits for their account to be unlocked' do
    context 'and then locks their account again by entering the wrong password' do
      context 'and then clicks on the old unlock link in their inbox' do
        it 'then an error message is displayed' do
          user.unlock_access!

          user.lock_access!

          visit user_unlock_path + "?unlock_token=#{token}"

          expect(page).to have_content('The link you followed has expired')
        end
      end
    end
  end
end
