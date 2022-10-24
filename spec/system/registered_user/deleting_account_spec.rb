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
  
  it 'has option to abort' do
    click_on 'Request to close account'
    click_on 'Cancel and go back to my account'
    expect(page).to have_current_path '/my-account'
  end
  
  let!(:note) { create(:note) }
  
  context 'when closing account' do
    before do
      click_on 'Request to close account'
      click_on 'Close my account'
    end
    
    it 'tells user account has been closed' do
      expect(page).to have_text 'Account closed'
    end
    
    it 'redacts information' do
      expect(User.first.first_name).to eq 'Redacted'
      expect(User.first.last_name).to eq 'User'
      expect(User.first.email).to have_text 'redacted_user'
      binding.pry
      expect(User.first.notes.first.body).to eq nil
      expect(User.first.ofsted_number).to eq nil
    end
  end
end
