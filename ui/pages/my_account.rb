# frozen_string_literal: true

module Pages
  class MyAccount < Base
    set_url '/my-account'

    element :name, '.govuk-summary-list__value', match: :first
    elements :list,'.govuk-summary-list__value'

    element :edit_name, "a[href='/my-account/edit-name']", text: 'Change'
    element :edit_email, "a[href='/my-account/edit-email']", text: 'Change'
    element :edit_password, "a[href='/my-account/edit-password']", text: 'Change'
    element :edit_postcode, "a[href='/my-account/edit-postcode']", text: 'Change'
    element :edit_ofsted_number, "a[href='/my-account/edit-ofsted-number']", text: 'Change'
    element :edit_setting_type, "a[href='/my-account/edit-setting-type']", text: 'Change'
    element :your_details_success_background, '.govuk-notification-banner--success'
  end
end
