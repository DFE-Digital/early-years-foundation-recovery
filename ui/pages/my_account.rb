# frozen_string_literal: true

module Pages
  class MyAccount < Base
    set_url '/my-account'

    element :name, '.govuk-summary-list__value', match: :first
    elements :list, '.govuk-summary-list__value'

    element :edit_name, '#edit_name_registration', text: 'Change'
    element :edit_email, '#edit_email_user', text: 'Change'

    load_validation { has_edit_name? }
    load_validation { has_edit_email? }
  end
end
