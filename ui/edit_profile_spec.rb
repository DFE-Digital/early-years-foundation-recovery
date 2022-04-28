# frozen_string_literal: true

describe 'Edit Profile', er_1: true do
  let(:ui) { Ui.new }

  before do
    ui.home.load
    ui.home.header.sign_in.click

    ui.sign_in.with_email_and_password

    ui.home.displayed?(5)

    ui.home.header.profile.click

    ui.profile.displayed?
    ui.profile.wait_until_first_name_visible
  end

  after do
    # Capybara.current_session.driver.quit
    browser = Capybara.current_session.driver.browser
    browser.manage.delete_all_cookies
  end

  context 'when an existing user' do
    it 'then the first name alone is updated when requested' do
      expected_first_name = Faker::Name.first_name
      ui.profile.first_name.set expected_first_name
      ui.profile.update_button.click

      ui.user.displayed?(5)
      ui.user.wait_until_edit_visible
      ui.user.edit.click

      actual_first_name = ui.profile.first_name.value
      expect(actual_first_name).to eq(expected_first_name)
    end

    it 'then the last name alone is updated when requested' do
      expected_last_name = Faker::Name.last_name
      ui.profile.last_name.set expected_last_name
      ui.profile.update_button.click

      ui.user.displayed?(5)
      ui.user.wait_until_edit_visible
      ui.user.edit.click

      actual_last_name = ui.profile.last_name.value
      expect(actual_last_name).to eq(expected_last_name)
    end

    it 'then the postcode alone is updated when requested' do
      expected_post_code = Faker::Address.postcode
      ui.profile.post_code.set expected_post_code
      ui.profile.update_button.click

      ui.user.displayed?(5)
      ui.user.wait_until_edit_visible
      ui.user.edit.click

      actual_post_code = ui.profile.post_code.value
      expect(actual_post_code).to eq(expected_post_code)
    end

    it 'then the ofsted number alone is updated when requested' do
      expected_ofsted_number = Faker::Number.number(digits: 10).to_s
      ui.profile.ofsted_number.set expected_ofsted_number
      ui.profile.update_button.click

      ui.user.displayed?(5)
      ui.user.wait_until_edit_visible
      ui.user.edit.click

      actual_ofsted_number = ui.profile.ofsted_number.value
      expect(actual_ofsted_number).to eq(expected_ofsted_number)
    end

    it 'then the changes to the first name, last name, postcode and ofsted number occurs' do
      expected_first_name = Faker::Name.first_name
      expected_last_name = Faker::Name.last_name
      expected_post_code = Faker::Address.postcode
      expected_ofsted_number = Faker::Number.number(digits: 10).to_s

      ui.profile.first_name.set expected_first_name
      ui.profile.last_name.set expected_last_name
      ui.profile.post_code.set expected_post_code
      ui.profile.ofsted_number.set expected_ofsted_number

      ui.profile.update_button.click

      ui.user.displayed?(5)
      ui.user.wait_until_edit_visible
      ui.user.edit.click

      actual_first_name = ui.profile.first_name.value
      actual_last_name = ui.profile.last_name.value
      actual_post_code = ui.profile.post_code.value
      actual_ofsted_number = ui.profile.ofsted_number.value

      expect(actual_first_name).to eq(expected_first_name)
      expect(actual_last_name).to eq(expected_last_name)
      expect(actual_post_code).to eq(expected_post_code)
      expect(actual_ofsted_number).to eq(expected_ofsted_number)
    end
  end
end
