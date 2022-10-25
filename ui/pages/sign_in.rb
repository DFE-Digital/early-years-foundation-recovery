# frozen_string_literal: true

module Pages
  class SignIn < Base
    set_url '/users/sign-in'

    element :email_field, '#user-email-field'
    element :password_field, '#user-password-field'
    element :sign_in_button, 'button.govuk-button', text: 'Sign in'
    element :warning_title, '#govuk-notification-banner-title', text: 'Warning'
    element :problem_signing_in, '.govuk-details__summary-text'
    element :forgotten_my_password_link, '.govuk-link', text: 'I have forgotten my password'
    # Authenticate using email and password
    #
    # @param email [String] login email address (default: completed@example.com)
    # @param password [String] login password (default: StrongPassword)
    def with_email_and_password(email = nil, password = nil)
      wait_until_header_visible

      email ||= 'completed@example.com'
      password ||= ENV.fetch('USER_PASSWORD', 'StrongPassword')

      email_field.set(email)
      password_field.set(password)
      sign_in_button.click
    end
  end
end
