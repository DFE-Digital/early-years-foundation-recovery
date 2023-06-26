require 'system_helper'

RSpec.describe 'User following forgotten password process' do
  let(:user) { create :user, :confirmed }
  let(:token) { user.send_reset_password_instructions }
  let(:password) { 'ABCDE123xyh' }

  context 'when choosing a new password' do
    before do
      visit edit_user_password_path + "?reset_password_token=#{token}"
    end

    # Happy path scenario
    context 'and new password meets criteria' do
      let(:password) { 'NewPassword123' }

      it 'flash message displays correctly' do
        fill_in 'New password', with: password
        fill_in 'Confirm password', with: password
        click_on 'Reset password'

        expect(page).to have_current_path(new_user_session_path)
          .and have_text('Success')
          .and have_text('Your new password has been saved.')
      end
    end

    # Unhappy path scenarios
    context 'and password is less than 10 characters' do
      let(:password) { 'Password' }

      it 'displays error message' do
        fill_in 'New password', with: password
        fill_in 'Confirm password', with: password
        click_on 'Reset password'

        expect(page).to have_text('Password must be at least 10 characters.')
      end
    end

    context "and password and confirm password don't match" do
      let(:password) { 'NewPassword123' }
      let(:confirm_password) { 'NewPassword456' }

      it 'displays error message' do
        fill_in 'New password', with: password
        fill_in 'Confirm password', with: confirm_password
        click_on 'Reset password'

        expect(page).to have_text("Sorry, your passwords don't match.")
      end
    end
  end

  context 'when entering valid email address' do
    it 'shows "Check email" page' do
      pending "Capybara::Cuprite::MouseEventFailed: Firing a click at coordinates [369.19140625, 903.25] failed. Cuprite detected another element with CSS selector 'html.govuk-template body.govuk-template__body.govuk-body.js-enabled div.govuk-width-container main#main-content.govuk-main-wrapper div.govuk-grid-row div.govuk-grid-column-two-thirds-from-desktop form#new_user.new_user fieldset.govuk-fieldset' at this position. It may be overlapping the element you are trying to interact with. If you dont care about overlapping elements, try using node.trigger('click').  "
      visit new_user_session_path
      click_link 'I have forgotten my password', visible: false

      expect(page).to have_text('I have forgotten my password')

      fill_in 'Email', with: user.email
      click_button 'Send email'

      expect(page).to have_text('Check your email')
    end
  end

  # context 'when navigating to reset password page' do
  #   before do
  #     visit check_email_password_reset_user_path
  #   end

  #   it 'provides link to resend the email' do
  #     click_link 'Send me another email', visible: false

  #     expect(page).to have_current_path(new_user_password_path)
  #   end

  #   it 'provides link text contact us' do
  #     expect(page).to have_text('contact us')
  #   end
  # end

  context 'when navigating to the "Check email" page' do
    it 'provides back button to sign in page' do
      visit check_email_password_reset_user_path
      click_link 'Back'

      expect(page).to have_current_path(new_user_session_path)
    end
  end
end
