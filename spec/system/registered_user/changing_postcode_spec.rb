require 'rails_helper'

RSpec.describe 'Registered user changing postcode', type: :system do
  include_context 'with user'

  let(:postcode) { user.postcode }

  before do
    visit '/my-account/edit-postcode'
    fill_in "Your setting's postcode", with: postcode
  end

  context 'when valid' do
    let(:postcode) { 'wd180dn' }

    it 'updates postcode' do
      click_button 'Save'

      expect(page).to have_current_path '/my-account'
      expect(page).to have_text('Manage your account')
        .and have_text('You have saved your details')
        .and have_text('WD18 0DN')
    end
  end

  context 'when invalid' do
    let(:postcode) { 'foo' }

    it 'renders an error message' do
      click_button 'Save'

      expect(page).to have_text "Your setting's postcode is invalid."
    end
  end

  context 'when empty' do
    let(:postcode) { '' }

    it 'renders an error message' do
      click_button 'Save'

      expect(page).to have_text "Enter your setting's postcode."
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
