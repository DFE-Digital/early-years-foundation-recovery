# frozen_string_literal: true

module Pages
  class EditName < Base
    set_url '/my-account/edit-name'

    element :first_name_field, '#user-first-name-field'
    element :last_name_field, '#user-last-name-field'
    element :button, 'button.govuk-button'
  end
end
