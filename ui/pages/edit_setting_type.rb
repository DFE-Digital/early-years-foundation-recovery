# frozen_string_literal: true

module Pages
  class EditSettingType < Base
    set_url '/my-account/edit-setting-type'

    element :nursery_radio_button, '#user-setting-type-nursery-field'
    element :childminder_radio_button, '#user-setting-type-childminder-field'
    element :school_radio_button, '.govuk-radios__label', text: 'School'
    element :other_radio_button,  '.govuk-radios__label', text: 'Other'
    element :other_setting_field, '#user-setting-type-other-field'
    element :nursery_radio_button2, './/label[contains(text(),"nursery")]/input[@id="user-setting-type-nursery-field"]'

    element :button, 'button.govuk-button', text: 'Save'
  end
end
