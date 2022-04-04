# Pages namespace
module Pages
  class SignIn < SitePrism::Page
    set_url_matcher %r{users/sign_in}

    element :email, '#user-email-field'
    element :password, '#user-password-field'
    element :sign_in_button, 'button.govuk-button'

    section :header, Sections::Header, '.govuk-header'
  end
end
