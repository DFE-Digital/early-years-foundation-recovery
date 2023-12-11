require 'rails_helper'

RSpec.describe 'Account page', type: :system do
  subject(:user) { create :user, :registered }

  include_context 'with user'

  context 'when gov_one login is disabled' do
    before do
      allow(Rails.application).to receive(:gov_one_login?).and_return(false)
      visit '/my-account'
    end

    it 'displays account details and password options' do
      expect(page).to have_text('Manage your account')
      expect(page).to have_css('a', text: 'Change name')
      expect(page).to have_css('a', text: 'Change password')
      expect(page).to have_css('a', text: 'Change setting details')
      expect(page).to have_css('a', text: 'Change email preferences')
      expect(page).to have_text('Closing your account')
    end
  end

  context 'when gov_one login is enabled' do
    before do
      allow(Rails.application).to receive(:gov_one_login?).and_return(true)
      visit '/my-account'
    end

    it 'password options are not listed and helper text is displayed' do
      expect(page).to have_text('Manage your account')
      expect(page).not_to have_css('a', text: 'Change password')
      expect(page).to have_content('Changing your name on this account will not affect your Gov.UK One Login account')
    end
  end
end
