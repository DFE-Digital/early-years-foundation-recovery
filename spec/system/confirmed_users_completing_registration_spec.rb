require 'rails_helper'

RSpec.describe 'Confirmed users completing registration' do
  include_context 'with user'

  let(:user) { create :user, :confirmed }

  context 'when I am a confirmed user' do
    it 'provides user to complete registration' do
      expect(page).to have_text('About you')

      fill_in 'First name', with: 'Jane'
      fill_in 'Surname', with: 'Doe'
      click_button 'Continue'

      expect(page).to have_text('About your setting')

      choose 'Nursery'
      fill_in "Your setting's postcode", with: 'SE6 2TS'
      fill_in "Your setting's Ofsted number", with: '1234567'
      click_button 'Complete'

      expect(page).to have_text('Success')
        .and have_text('Thank you for creating a child development training account.')
    end

    it 'requires name and a setting type and a valid setting postcode to be complete' do
      click_button 'Continue'

      expect(page).to have_text('There is a problem')
        .and have_text('Enter a first name.')
        .and have_text('Enter a surname.')

      fill_in 'First name', with: 'Jane'
      fill_in 'Surname', with: 'Doe'
      click_button 'Continue'

      expect(page).to have_text('About your setting')

      fill_in "Your setting's postcode", with: ''
      click_button 'Complete'

      expect(page).to have_text('There is a problem')
        .and have_text("Enter your setting's postcode.")
        .and have_text('Select a setting type.')

      choose 'Nursery'
      fill_in "Your setting's postcode", with: 'foo'
      click_button 'Complete'

      expect(page).to have_text('There is a problem')
        .and have_text("Your setting's postcode is invalid.")
    end
  end
end
