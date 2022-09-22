require 'rails_helper'

RSpec.describe 'Sign up', type: :system do
  before do
    visit '/users/sign-up'
  end

  context 'when user does not exist' do
    let(:user) { create(:user) }

    it 'must accept terms and conditions' do
      fill_in 'Email address', with: user.email
      fill_in 'Create password', with: user.password
      fill_in 'Confirm password', with: user.password
      click_button 'Continue'

      expect(page).to have_text('There is a problem')
        .and have_text('You must accept the terms and conditions and privacy policy to create an account.')
    end
  end
  

  # DONT MERGE ME - JUST FOR TESTING ---------------------------
  context 'when user does not exist' do
    let(:user) { create(:user) }

    it 'must accept terms and conditions' do
      fill_in 'Email address', with: user.email
      fill_in 'Create password', with: user.password
      fill_in 'Confirm password', with: user.password
      click_button 'Continue'

      expect(page).to have_current_path '/users/sign-up'
    end
  end
  # -----------------------------------------------------------

  context 'when user already exists' do
    let(:user) { create(:user, :registered) }

    # re-registration / enumeration exploit
    it 'does not expose email accounts' do
      fill_in 'Email address', with: user.email
      fill_in 'Create password', with: user.password
      fill_in 'Confirm password', with: user.password
      check 'I confirm that I accept the terms and conditions and privacy policy.'
      click_button 'Continue'

      expect(page).to have_text('We sent the email to').and have_text(user.email)

      expect(page).not_to have_text('There is a problem')
      expect(page).not_to have_text('has already been taken')
    end
  end
end
