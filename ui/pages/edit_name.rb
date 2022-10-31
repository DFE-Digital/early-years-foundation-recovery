# frozen_string_literal: true

module Pages
  class EditName < Base
    set_url '/registration/name/edit'

    element :first_name_field, '#user-first-name-field'
    element :last_name_field, '#user-last-name-field'
    element :button, 'button.govuk-button', text: 'Save'
  end
end
