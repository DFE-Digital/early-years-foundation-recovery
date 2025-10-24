require 'rails_helper'

RSpec.describe 'Registration' do
  include_context 'with user'

  let(:user) { create :user }

  before do
    visit '/registration/terms-and-conditions/edit'
  end

  it 'can be completed when other setting is chosen' do
    # T&Cs
    expect(page).to have_current_path '/registration/terms-and-conditions/edit'
    expect(page).to have_text 'Terms and conditions'
    click_button 'Continue'
    expect(page).to have_text('There is a problem')
      .and have_text('You must accept the terms and conditions and privacy policy to create an account.')
    expect(page).to have_text 'Agree to our terms and conditions'
    check 'I confirm that I accept the terms and conditions and privacy policy.'
    click_button 'Continue'

    # Name
    expect(page).to have_current_path '/registration/name/edit'
    expect(page).to have_text 'About you'
    click_button 'Continue'
    expect(page).to have_text('There is a problem')
      .and have_text('Enter a first name.')
      .and have_text('Enter a surname.')

    fill_in 'First name', with: 'Jane'
    fill_in 'Surname', with: 'Doe'
    click_button 'Continue'

    # Setting
    expect(page).to have_current_path '/registration/setting-type/edit'
    expect(page).to have_text 'What setting type do you work in?'
    click_button 'Continue'
    expect(page).to have_text('There is a problem')
      .and have_text('Enter the setting type you work in.')
    click_link 'I cannot find my setting or organisation'

    # Custom setting
    expect(page).to have_current_path '/registration/setting-type-other/edit'
    expect(page).to have_text('Where do you work?')
      .and have_text('Enter the type of setting or organisation where you work.')
    fill_in 'user-setting-type-other-field', with: 'user defined setting type'
    click_button 'Continue'

    # Role
    expect(page).to have_current_path '/registration/role-type/edit'
    expect(page).to have_text 'Which of the following best describes your role?'
    click_button 'Continue'
    expect(page).to have_text('There is a problem')
      .and have_text('Select your role.')
    click_link 'I would describe my role in another way.'

    # Custom role
    expect(page).to have_current_path '/registration/role-type-other/edit'
    expect(page).to have_text('What is your role?')
      .and have_text('Enter your job title.')
    click_button 'Continue'
    expect(page).to have_text('There is a problem')
      .and have_text('Enter your job title.')
    fill_in 'Enter your job title.', with: 'user defined job title'
    click_button 'Continue'

    # Years experience
    expect(page).to have_current_path '/registration/early-years-experience/edit'
    expect(page).to have_text 'How long have you worked in early years?'
    click_button 'Continue'
    expect(page).to have_text('There is a problem')
      .and have_text('Choose an option.')
    choose 'Less than 2 years'
    click_button 'Continue'

    # Email preference
    expect(page).to have_current_path '/registration/training-emails/edit'
    expect(page).to have_text 'Do you want to get email updates about this training course?'
    click_button 'Continue'
    expect(page).to have_text('There is a problem')
      .and have_text('Choose an option.')
    choose 'Send me email updates about this training course'
    click_button 'Continue'

    # End
    expect(page).to have_text 'You can now start your first module.'
  end

  it 'can be completed with a standard setting that requires local authority' do
    visit '/registration/terms-and-conditions/edit'

    # T&Cs
    check 'I confirm that I accept the terms and conditions and privacy policy.'
    click_button 'Continue'

    # Name
    fill_in 'First name', with: 'John'
    fill_in 'Surname', with: 'Smith'
    click_button 'Continue'

    # Setting
    expect(page).to have_current_path '/registration/setting-type/edit'
    select 'Local authority maintained nursery school', from: 'user[setting_type_id]'
    click_button 'Continue'

    # Local authority
    expect(page).to have_current_path '/registration/local-authority/edit'
    expect(page).to have_text('What local authority area do you work in?')
      .and have_text('This could be your county council, district council or London borough.')
    click_link 'I work across more than one local authority'

    # Role
    expect(page).to have_current_path '/registration/role-type/edit'
    choose 'Student'
    click_button 'Continue'

    # Years experience
    expect(page).to have_current_path '/registration/early-years-experience/edit'
    choose 'Less than 2 years'
    click_button 'Continue'

    # Email preference
    expect(page).to have_current_path '/registration/training-emails/edit'
    choose 'Send me email updates about this training course'
    click_button 'Continue'

    # End
    expect(page).to have_text 'You can now start your first module.'
  end
end
