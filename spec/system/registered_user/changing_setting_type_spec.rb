require 'rails_helper'

RSpec.describe 'Registered user changing setting type', type: :system do
  include_context 'with user'

  let(:setting_type) { user.setting_type }

  before do
    visit '/my-account/edit-setting-type'
  end

  context 'when I am in my account section and update my setting type' do
    let(:updated_setting_type) { 'nursery' }

    it 'can update successfully' do
      choose updated_setting_type.capitalize
      click_button 'Save'

      expect(page).to have_current_path '/my-account'
      expect(page).to have_text('Manage your account')
        .and have_text('Nursery')
    end

    it 'displays success message' do
      choose updated_setting_type.capitalize
      click_button 'Save'

      expect(page).to have_text('You have saved your details')
    end
  end

  context 'when updating setting type to other' do
    let(:updated_setting_type) { 'other' }
    let(:setting_type_other) { 'Foo' }

    it 'displays user entered setting' do
      choose updated_setting_type.capitalize
      fill_in 'Other setting', with: setting_type_other
      click_button 'Save'

      expect(page).to have_current_path '/my-account'
      expect(page).to have_text('Manage your account').and have_text('Foo')
    end
  end

  context 'when cancelled' do
    it 'returns to account page' do
      click_link 'Cancel'

      expect(page).to have_current_path '/my-account'
      expect(page).to have_text('Manage your account').and have_text('School')
    end
  end
end
