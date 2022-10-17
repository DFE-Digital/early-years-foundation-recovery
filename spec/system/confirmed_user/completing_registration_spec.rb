require 'rails_helper'

RSpec.describe 'Confirmed users completing registration' do
  include_context 'with user'

  let(:user) { create :user, :confirmed }

  it 'provides user to complete registration' do
    expect(page).to have_text('About you')

    fill_in 'First name', with: 'Jane'
    fill_in 'Surname', with: 'Doe'
    click_button 'Continue'

    expect(page).to have_text('What setting type do you work in?')

    save_and_open_page
    fill_in 'user-setting-type-field-select', with: 'Nu'
    expect(page).to have_text 'Local authority maintained nursery school'
      .and have_text 'Private nursery'
      .and have_text 'Independent nursery'
      .and have_text 'Nursery attached to school'
    click 'Independent nursery'

    click_button 'Continue'

    expect(page).to have_text('What local authority area do you work in?')
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
