require 'rails_helper'

RSpec.describe 'Registered user changing setting type', type: :system do
  include_context 'with user'

  let(:setting_type) { user.setting_type }

  before do
    visit '/my-account/edit-setting-type'
    fill_in 'Your setting type', with: setting_type
  end

  context 'when valid' do
    let(:setting_type) { 'nursery' }

    it 'updates setting type' do
      click_button 'Save'

      expect(page).to have_current_path '/my-account'
      expect(page).to have_text('Manage your account')
        .and have_text('You have saved your details')
        .and have_text('Nursery')
    end
  end

  context 'when other' do
    let(:setting_type) { 'other' }
    let(:setting_type_other) { 'Foo' }

    it 'updates setting type' do
      fill_in 'Other', with: setting_type_other
      click_button 'Save'

      expect(page).to have_current_path '/my-account'
      expect(page).to have_text('Manage your account')
        .and have_text('You have saved your details')
        .and have_text('Foo')
    end
  end

  context 'when cancelled' do
    it 'returns to account page' do
      click_link 'Cancel'

      expect(page).to have_current_path '/my-account'
      expect(page).to have_text('Manage your account')
        .and have_text('You have saved your details')
        .and have_text('School')
    end
  end
end
