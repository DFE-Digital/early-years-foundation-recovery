require 'rails_helper'

RSpec.describe 'Registered user changing setting type', type: :system do
  include_context 'with user'

  let(:setting_type) { user.setting_type }

  before do
    visit '/my-account/edit-setting-type'
  end

  context 'when valid' do
    let(:updated_setting_type) { 'nursery' }

    it 'updates setting type' do
      choose updated_setting_type.capitalize
      click_button 'Save'

      expect(page).to have_current_path '/my-account'
      expect(page).to have_text('Manage your account')
        .and have_text('You have saved your details')
        .and have_text('Nursery')
    end
  end

  context 'when other' do
    let(:updated_setting_type) { 'other' }
    let(:setting_type_other) { 'Foo' }

    it 'updates setting type' do
      choose updated_setting_type.capitalize
      fill_in 'Other setting', with: setting_type_other
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
