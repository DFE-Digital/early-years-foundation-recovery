require 'rails_helper'

RSpec.describe 'Account deletion' do
  include_context 'with user'
  
  it 'has button to close account' do
    visit '/my-account'
    click_on 'Request to close account'
    expect(page).to have_current_path '/my-account/account-deletion/edit'
  end

  context 'when on enter password screen' do
    before do
      visit '/my-account/account-deletion/edit'
    end

    it 'can continue with correct password' do
      fill_in 'Enter your current password', with: user.password
      click_on 'Continue'
      expect(page).to have_current_path '/my-account/account-deletion/confirm-delete-account'
    end

    it 'cannot continue with incorrect password' do
      fill_in 'Enter your current password', with: user.password
      click_on 'Continue'
      expect(page).to have_content ''
    end

    it 'has option to abort' do
      click_on 'Back'
      expect(page).to have_current_path '/my-account'
    end
  end

  context 'when on confirmation page' do
    let!(:note) { create(:note) }
    
    before do
      user.notes.push(note)
      user.save!
      visit '/my-account/account-deletion/confirm-delete-account'
    end
    
    it 'has option to abort' do
      click_on 'Cancel and go back to my account'  
      expect(page).to have_current_path '/my-account'
    end
    
    it 'can close account' do
      click_on 'Close my account'
      
      expect(page).to have_text 'Account closed'
    end
    
    it 'redacts information' do
      click_on 'Close my account'
      binding.pry
      expect(User.first.first_name).to eq 'Redacted'
      expect(User.first.last_name).to eq 'User'
      expect(User.first.email).to have_text 'redacted_user'
      expect(User.first.notes.first.body).to eq nil
      expect(User.first.valid_password?('redacteduser')).to eq true
      expect(User.first.ofsted_number).to eq ''
    end
  end
end
