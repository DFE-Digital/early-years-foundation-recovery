require 'rails_helper'

RSpec.describe 'Sign up', type: :system do
  before do
    visit '/users/sign-up'
  end

  context 'when user already exists' do
    let(:user) { create(:user, :registered) }

    # re-registration / enumeration exploit
    it 'does not expose email accounts' do
      fill_in 'Email address', with: user.email
      fill_in 'Create password', with: 'StrongPassword123'
      fill_in 'Confirm password', with: 'StrongPassword123'
      click_button 'Continue'

      expect(page).to have_text('We sent the email to').and have_text(user.email)

      expect(page).not_to have_text('There is a problem')
      expect(page).not_to have_text('has already been taken')
    end
  end
end
