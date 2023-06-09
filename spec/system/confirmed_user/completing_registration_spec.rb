require 'rails_helper'

RSpec.describe 'Confirmed users completing registration' do
  include_context 'with user'

  let(:user) { create :user, :confirmed }

  it 'requires name and a setting type and email preferences and a complete' do
    expect(page).to have_text('About you')
    click_button 'Continue'

    expect(page).to have_text('There is a problem')
      .and have_text('Enter a first name.')
      .and have_text('Enter a surname.')

    fill_in 'First name', with: 'Jane'
    fill_in 'Surname', with: 'Doe'
    click_button 'Continue'

    expect(page).to have_text('What setting type do you work in?')

    click_button 'Continue'

    expect(page).to have_text('There is a problem')
      .and have_text('Enter the setting type you work in.')

    click_link 'I cannot find my setting or organisation'

    expect(page).to have_text('Where do you work?')
      .and have_text('Enter the type of setting or organisation where you work.')

    fill_in 'user-setting-type-other-field', with: 'user defined setting type'
    click_button 'Continue'

    expect(page).to have_text('What local authority area do you work in?')
      .and have_text('This could be your county council, district council or London borough.')

    click_link 'I work across more than one local authority'

    expect(page).to have_text('Which of the following best describes your role?')

    click_button 'Continue'

    expect(page).to have_text('There is a problem')
      .and have_text('Select your role.')

    click_link 'I would describe my role in another way.'

    expect(page).to have_text('What is your role?')
      .and have_text('Enter your job title.')

    click_button 'Continue'

    expect(page).to have_text('There is a problem')
      .and have_text('Enter your job title.')

    fill_in 'Enter your job title.', with: 'user defined job title'

    click_button 'Continue'

    expect(page).to have_text('Do you want to get email updates about this training course?')

    click_button 'Continue'

    expect(page).to have_text('There is a problem')
      .and have_text('Choose an option.')

    choose 'Send me email updates about this training course'

    click_button 'Continue'

    expect(page).to have_text('Do you want to get early years email updates from the Department for Education?')

    click_button 'Continue'

    expect(page).to have_text('There is a problem')
      .and have_text('Choose an option.')

    choose 'Send me early years email updates'

    click_button 'Continue'

    expect(page).to have_text('Thank you for creating an Early years child development training account. You can now start the first module.')
  end
end
