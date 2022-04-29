module Pages
  class SignUp < SitePrism::Page
    set_url_matcher %r{users/sign_up}

    element :email, '#user-email-field'
    element :password, '#user-password-field'
    element :confirm_password, '#user-password-confirmation-field'
    element :continue, 'button[class="govuk-button"]'
  end
end