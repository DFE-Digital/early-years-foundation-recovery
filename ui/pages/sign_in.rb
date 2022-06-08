# frozen_string_literal: true

module Pages
  class SignIn < Base
    set_url '/users/sign_in'

    element :email_field, '#user-email-field'
    element :password_field, '#user-password-field'
    element :sign_in_button, 'button.govuk-button'

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
