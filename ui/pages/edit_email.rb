# frozen_string_literal: true

module Pages
  class EditEmail < Base
    set_url '/my-account/edit-email'

    element :email_address_field, '#user-email-field'
    element :button, 'button.govuk-button', text: 'Save'
  end
end
