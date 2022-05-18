require 'rails_helper'

RSpec.describe 'Registered user changing name', type: :system do
  include_context 'with registered user'

  before do
    visit '/user/edit_name'
  end

  context 'when valid' do
    it 'updates name' do
      fill_in 'First name', with: 'Foo'
      fill_in 'Surname', with: 'Bar'
      click_button 'Save'

      expect(page).to have_current_path '/user'
      expect(page).to have_text('Manage your account')
        .and have_text('You have saved your details')
        .and have_text('Foo Bar')
    end
  end

  context 'when empty' do
    it 'renders an error message' do
      fill_in 'First name', with: ''
      fill_in 'Surname', with: ''
      click_button 'Save'

      expect(page).to have_text 'Enter a first name.'
      expect(page).to have_text 'Enter a surname.'
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
