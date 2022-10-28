require 'rails_helper'

RSpec.describe 'Registered user changing name', type: :system do
  include_context 'with user'

  before do
    visit '/registration/name/edit'
  end

  context 'when valid' do
    it 'updates name' do
      fill_in 'First name', with: 'Foo'
      fill_in 'Surname', with: 'Bar'
      click_button 'Continue'

      expect(page).to have_current_path '/my-account'
      expect(page).to have_text('Manage your account')
        .and have_text('Foo Bar')
    end
  end

  context 'when empty' do
    it 'renders an error message' do
      fill_in 'First name', with: ''
      fill_in 'Surname', with: ''
      click_button 'Continue'

      expect(page).to have_text 'Enter a first name.'
      expect(page).to have_text 'Enter a surname.'
    end
  end

  context 'when cancelled' do
    it 'returns to account page' do
      click_link 'Back'

      expect(page).to have_current_path '/my-account'
    end
  end
end
