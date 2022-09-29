# frozen_string_literal: true

module Pages
  class EditPassword < Base
    set_url '/my-account/edit-password'

    element :current_password_field, '#user-current-password-field'
    element :new_password_field, '#user-password-field'
    element :confirm_password_field, '#user-password-confirmation-field'
    element :button, 'button.govuk-button', text: 'Save'
  end
end
