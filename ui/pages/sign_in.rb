module Pages
  class SignIn < SitePrism::Page
    set_url_matcher %r{users/sign_in}

    element :email_locator, '#user-email-field'
    element :password_locator, '#user-password-field'
    element :sign_in_button, 'button.govuk-button'
    element :create_account, 'a[href="/users/sign_up"]'


    section :header, Sections::Header, '.govuk-header'

    # Convenience method to login with the email address and password strings
    #
    # @param email [String] login email address
    # @param password [String] login password
    def with_email_and_password(email = nil, password = nil)
      wait_until_header_visible
      email_locator.set email || 'completed@example.com'
      password_locator.set password || ENV.fetch('USER_PASSWORD', 'password')
      sign_in_button.click
    end
  end
end
