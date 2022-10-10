require 'rails_helper'

RSpec.describe 'Account deletion' do
  include_context 'with user'

  before do
    visit '/my-account'
  end

  it 'has confirmation step' do
    click_on 'Request to close account'

    expect(page).to have_text 'Are you sure you would like to close your account?'
  end

  it 'tells user account has been closed' do
    click_on 'Request to close account'
    click_on 'Close my account'

    expect(page).to have_text "Account closed"
  end
  
  it 'has option to abort' do
    click_on 'Request to close account'
    click_on 'Cancel and go back to my account'
    expect(page).to have_current_path '/my-account' 
  end
end