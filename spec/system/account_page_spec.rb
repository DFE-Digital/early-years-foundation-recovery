require 'rails_helper'

RSpec.describe 'Account page', type: :system do
  include_context 'with user'

  before do
    visit '/my-account'
  end

  it 'displays account details' do
    expect(page).to have_text 'Manage your account'
    expect(page).to have_link 'Change name'

    if Rails.application.gov_one_login?
      expect(page).not_to have_link 'Change password'
      expect(page).to have_content 'This is the name that will appear on your end of module certificate'
      expect(page).to have_content 'Changing your name on this account will not affect your GOV.UK One Login'
    else
      expect(page).to have_link 'Change password'
    end

    expect(page).to have_link 'Change setting details'
    expect(page).to have_link 'Change email preferences'

    expect(page).to have_text 'Closing your account'
  end
end
