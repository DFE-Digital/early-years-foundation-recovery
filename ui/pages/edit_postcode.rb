# frozen_string_literal: true

module Pages
  class EditPostcode < Base
    set_url '/my-account/edit-postcode'

    element :postcode_field, '#user-postcode-field'
    element :error_summary_title, '#error-summary-title'
    element :button, 'button.govuk-button', text: 'Save'

    element :cancel, "a[href='/my-account']", text: 'Cancel'

  end
end
