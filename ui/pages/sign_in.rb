# Pages namespace to include all pages in the application.
module Pages
  # Sing in page POM.
  class SignIn < SitePrism::Page
    set_url_matcher %r{users/sign_in}

    element :email_locator, '#user-email-field'
    element :password_locator, '#user-password-field'
    element :sign_in_button, 'button.govuk-button'

    section :header, Sections::Header, '.govuk-header'

    # Convenience method to login with the email address and password strings
    #
    # @param [String] email address String
    # @param [String] password string
    def with_email_and_password(email, password)
      wait_until_header_visible
      email_locator.set email
      password_locator.set password
      sign_in_button.click
    end
  end
end
