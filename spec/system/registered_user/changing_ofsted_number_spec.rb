require 'rails_helper'

RSpec.describe 'Registered user changing Ofsted number', type: :system do
  subject(:user) { create :user, :registered, ofsted_number: '12345678' }

  include_context 'with user'

  let(:ofsted_number) { user.ofsted_number }

  before do
    visit '/my-account/edit-ofsted-number'
    fill_in "Your setting's Ofsted number", with: ofsted_number
  end

  context 'when successful' do
    let(:ofsted_number) { 'vc123456' }

    it 'updates Ofsted number' do
      click_button 'Save'

      expect(page).to have_current_path '/my-account'
      expect(page).to have_text('Manage your account')
        .and have_text('You have saved your details')
        .and have_text('VC123456')
    end
  end

  context 'when invalid' do
    let(:ofsted_number) { 'foo' }

    it 'renders an error message' do
      click_button 'Save'

      expect(page).to have_text('This Ofsted number is not recognised.')
    end
  end

  context 'when empty' do
    let(:ofsted_number) { '' }

    it 'deletes the saved Ofsted number' do
      click_button 'Save'

      expect(page).to have_current_path '/my-account'
      expect(page).to have_text 'You have saved your details'
      expect(page).not_to have_text '12345678'
    end
  end

  context 'when cancelled' do
    it 'returns to account page' do
      click_link 'Cancel'

      expect(page).to have_current_path '/my-account'
      expect(page).not_to have_text 'You have saved your details'
    end
  end
end
