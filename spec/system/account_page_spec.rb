require 'rails_helper'

RSpec.describe 'Account page', type: :system do
  include_context 'with user'

  before do
    visit '/my-account'
  end

  it 'displays account details' do
    expect(page).to have_text 'Manage your account'
    expect(page).to have_link 'Change name'

    expect(page).not_to have_link 'Change password'
    expect(page).to have_content 'This is the name that will appear on your end of module certificate'
    expect(page).to have_content 'Changing your name on this account will not affect your GOV.UK One Login'

    expect(page).to have_link 'Change setting details'
    expect(page).to have_link 'Change email preferences'

    expect(page).to have_text 'Closing your account'
  end

  describe 'edit details' do
    it 'user defined answers' do
      click_on 'Change setting details'
      expect(page).to have_current_path '/registration/setting-type/edit'

      click_on 'I cannot find my setting or organisation'
      expect(page).to have_current_path '/registration/setting-type-other/edit'

      fill_in 'Enter the type of setting or organisation where you work.', with: 'DfE'
      click_button 'Continue'
      expect(page).to have_current_path '/registration/local-authority/edit'

      click_on 'I work across more than one local authority'
      expect(page).to have_current_path '/registration/role-type/edit'

      click_on 'I would describe my role in another way.'
      expect(page).to have_current_path '/registration/role-type-other/edit'

      fill_in 'Enter your job title.', with: 'Developer'
      click_button 'Continue'
      expect(page).to have_current_path '/registration/early-years-experience/edit'

      choose 'Not applicable'
      click_button 'Continue'

      expect(page).to have_current_path '/my-account'

      expect(page).to have_text 'DfE'
      expect(page).to have_text 'Developer'
      expect(page).to have_text 'Not applicable'
    end
  end
end
