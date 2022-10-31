# frozen_string_literal: true

module Pages
  class MyAccount < Base
    set_url '/my-account'

    element :name, '.govuk-summary-list__value', match: :first

    element :edit_name, "#edit_name_registration", text: 'Change'
  end
end
