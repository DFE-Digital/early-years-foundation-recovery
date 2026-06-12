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
    expect(page).to have_link 'Change', href: edit_registration_where_you_live_path
    expect(page).to have_text 'England'

    expect(page).to have_link 'Change email preferences'
    expect(page).to have_text 'You have chosen to receive emails about this training course.'

    expect(page).to have_link 'Change research preferences'
    expect(page).to have_text 'You have chosen not to participate in research.'

    expect(page).to have_text 'Closing your account'
  end

  it 'changes where you live from my details' do
    click_link(id: 'edit_where_you_live_registration')
    expect(page).to have_current_path '/registration/where-you-live/edit'

    choose 'Scotland'
    click_button 'Continue'

    expect(page).to have_current_path '/registration/setting-type/edit'

    visit '/my-account'
    expect(page).to have_text 'Scotland'
    expect(page).to have_text 'Not applicable'
    expect(page).not_to have_text 'Multiple'
  end

  describe 'edit details' do
    it 'user defined answers' do
      click_on 'Change setting details'
      expect(page).to have_current_path '/registration/setting-type/edit'

      click_on 'I cannot find my setting or organisation'
      expect(page).to have_current_path '/registration/setting-type-other/edit'

      fill_in 'Enter the type of setting or organisation where you work.', with: 'DfE Updated'
      click_button 'Continue'
      expect(page).to have_current_path '/my-account'

      expect(page).to have_text 'DfE Updated'
    end

    describe 'research participation preference' do
      before do
        user.update!(research_participant: true)
        visit '/my-account'
      end

      it 'changes response' do
        expect(page).to have_text 'You have chosen to participate in research.'
        click_on 'Change research preferences'
        expect(page).to have_current_path '/registration/research-participant/edit'
        choose 'No'
        click_button 'Save'
        expect(page).to have_current_path '/my-account'
        expect(page).to have_text 'You have chosen not to participate in research.'
        expect(page).to have_text 'You have updated your details'
      end
    end
  end
end
