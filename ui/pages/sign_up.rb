# frozen_string_literal: true

module Pages
  class SignUp < Base
    set_url '/users/sign-up'

    element :email_field, '#user-email-field'
    element :password_field, '#user-password-field'
    element :password_confirmation_field, '#user-password-confirmation-field'
    element :continue_button, 'button.govuk-button', text: 'Continue'
    element :error_summary_title, '#error-summary-title', text: 'There is a problem'
    element :terms_and_conditions_check_box, '.govuk-checkboxes__label', text:'I confirm that I accept the terms and conditions and privacy policy.'

    # Authenticate using email and password
    #
    # @param email [String] login email address (default: completed@example.com)
    # @param password [String] login password (default: StrongPassword)
    def with_email_and_password(email = nil, password = nil, confirmation = nil)
      wait_until_header_visible
      email ||= Faker::Internet.email
      password ||= ENV.fetch('USER_PASSWORD', 'StrongPassword')

      email_field.set(email)
      password_field.set(password)
      password_confirmation_field.set(password)
      terms_and_conditions_check_box.click
      continue_button.click
    end

    def with_blank_email_and_password(email = nil, password = nil)
      wait_until_header_visible

      email ||= ''
      password ||= ENV.fetch('USER_PASSWORD', 'StrongPassword')

      email_field.set(email)
      password_field.set(password)
      password_confirmation_field.set(password)
      continue_button.click

    end

    def with_invalid_email_and_password(email = nil, password = nil)
      wait_until_header_visible

      email ||= 'completedexample.com'
      password ||= ENV.fetch('USER_PASSWORD', 'Strong')

      email_field.set(email)
      password_field.set(password)
      password_confirmation_field.set(password)
      continue_button.click
    end

  end
end
