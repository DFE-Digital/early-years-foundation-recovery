# frozen_string_literal: true

describe 'Profile management' do
  include_context 'with user'

  before do
    ui.my_account.load
  end

  describe 'Your details' do
    it 'edit first name' do
      expect(ui.my_account).to be_displayed
      ui.my_account.edit_name.click
      expect(ui.edit_name).to be_displayed
      ui.edit_name.first_name_field.set 'Peter'
      ui.edit_name.button.click
      expect(ui.my_account).to be_displayed
      expect(ui.my_account.name).to have_text 'Peter'
    end

    it 'edit email' do
      expect(ui.my_account).to be_displayed
      ui.my_account.edit_email.click
      sleep(2)
      expect(ui.edit_email).to be_displayed
      ui.edit_email.email_address_field.set 'completed@example.com'
      ui.edit_email.button.click
      expect(ui.my_account).to be_displayed
      expect(ui.my_account).to have_content 'completed@example.com'
    end

    it 'edit postcode' do
      expect(ui.my_account).to be_displayed
      ui.my_account.edit_postcode.click
      expect(ui.edit_postcode).to be_displayed
      ui.edit_postcode.postcode_field.set 'SE2 OQG'
      ui.edit_postcode.button.click
      expect(ui.my_account).to be_displayed
      expect(ui.my_account).to have_content 'SE2 0QG'
    end

    it 'edit postcode with blank' do
      expect(ui.my_account).to be_displayed
      ui.my_account.edit_postcode.click
      expect(ui.edit_postcode).to be_displayed
      ui.edit_postcode.postcode_field.set ' '
      ui.edit_postcode.button.click
      expect(ui.edit_postcode).to have_error_summary_title
    end

    # ER-209: My account page unhappy path - Edit your settings post code
    it 'edit postcode with random' do
      expected_post_code = Faker::Address.postcode
      expect(ui.my_account).to be_displayed
      ui.my_account.edit_postcode.click
      expect(ui.edit_postcode).to be_displayed
      ui.edit_postcode.postcode_field.set expected_post_code
      ui.edit_postcode.button.click
      expect(ui.my_account).to have_content expected_post_code
      expect(ui.my_account.your_details_success_background.style('background-color')).to eq('background-color' => 'rgba(0, 112, 60, 1)')
      sleep(2)
    end

    it 'Ofsted number' do
      expect(ui.my_account).to be_displayed
      ui.my_account.edit_ofsted_number.click
      expect(ui.edit_ofsted_number).to be_displayed
      ui.edit_ofsted_number.ofsted_number_field.set 'EY295936'
      ui.edit_ofsted_number.button.click
      expect(ui.my_account).to be_displayed
      expect(ui.my_account).to have_content 'EY295936'
    end

    it 'edit setting type to Other' do
      expect(ui.my_account).to be_displayed
      ui.my_account.edit_setting_type.click
      sleep(10)
      expect(ui.edit_setting_type).to be_displayed
      ui.edit_setting_type.other_radio_button.click
      ui.edit_setting_type.other_setting_field.set 'OTHER SETTING'
      ui.edit_setting_type.button.click
      expect(ui.my_account).to be_displayed
      expect(ui.my_account).to have_content 'OTHER SETTING'
    end

    it 'edit setting type to School' do
      expect(ui.my_account).to be_displayed
      ui.my_account.edit_setting_type.click
      sleep(10)
      expect(ui.edit_setting_type).to be_displayed
      ui.edit_setting_type.school_radio_button.click
      ui.edit_setting_type.button.click
      expect(ui.my_account).to be_displayed
      expect(ui.my_account).to have_content 'School'
    end
  end
end
