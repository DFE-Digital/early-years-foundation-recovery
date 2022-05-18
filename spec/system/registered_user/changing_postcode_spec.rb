require 'rails_helper'

RSpec.describe 'Registered user changing postcode', type: :system do
  include_context 'with registered user'

  let(:postcode) { user.postcode }

  before do
    visit '/user/edit_postcode'
    fill_in "Setting's postcode", with: postcode
  end

  context 'when valid' do
    let(:postcode) { 'wd180dn' }

    it 'updates postcode' do
      click_button 'Save'

      expect(page).to have_current_path '/user'
      expect(page).to have_text('Manage your account')      # page heading
        .and have_text('You have saved your details')       # flash message
        .and have_text('WD18 0DN')
    end
  end

  context 'when invalid' do
    let(:postcode) { 'foo' }

    it 'renders an error message' do
      click_button 'Save'

      expect(page).to have_text "Enter your setting's postcode."
    end
  end

  context 'when missing' do
    let(:postcode) { '' }

    it 'renders an error message' do
      click_button 'Save'

      expect(page).to have_text "can't be blank"
    end
  end

  context 'when cancelled' do
    it 'returns to account page' do
      click_link 'Cancel'

      expect(page).to have_current_path '/user'
      expect(page).not_to have_text 'You have saved your details'
    end
  end
end
