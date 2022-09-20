# frozen_string_literal: true

module Pages
  class EditOfstedNumber < Base
    set_url '/my-account/edit-ofsted-number'

    element :ofsted_number_field, '#user-ofsted-number-field'
    element :button, 'button.govuk-button', text: 'Save'
  end
end
