# frozen_string_literal: true

require_relative './spec_helper'

describe 'Edit Profile' do
  let(:dfe) { Dfe.new }

  before do
    dfe.home.load
    dfe.home.header.sign_in.click

    dfe.sign_in.wait_until_header_visible
    dfe.sign_in.email.set ENV['USER']
    dfe.sign_in.password.set ENV['PASS']
    dfe.sign_in.sign_in_button.click

    dfe.home.displayed?(5)
    dfe.home.header.profile.click

    dfe.profile.displayed?
    dfe.profile.wait_until_first_name_visible
  end

  after do
    # Capybara.current_session.driver.quit
    browser = Capybara.current_session.driver.browser
    browser.manage.delete_all_cookies
  end

  context 'when an existing user' do
    it 'then the first name alone is updated when requested' do
      expected_first_name = Faker::Name.first_name
      dfe.profile.first_name.set expected_first_name
      dfe.profile.update_button.click

      dfe.user.displayed?(5)
      dfe.user.wait_until_edit_visible
      dfe.user.edit.click

      actual_first_name = dfe.profile.first_name.value
      expect(actual_first_name).to eq(expected_first_name)
    end

    it 'then the last name alone is updated when requested' do
      expected_last_name = Faker::Name.last_name
      dfe.profile.last_name.set expected_last_name
      dfe.profile.update_button.click

      dfe.user.displayed?(5)
      dfe.user.wait_until_edit_visible
      dfe.user.edit.click

      actual_last_name = dfe.profile.last_name.value
      expect(actual_last_name).to eq(expected_last_name)
    end

    it 'then the postcode alone is updated when requested' do
      expected_post_code = Faker::Address.postcode
      dfe.profile.post_code.set expected_post_code
      dfe.profile.update_button.click

      dfe.user.displayed?(5)
      dfe.user.wait_until_edit_visible
      dfe.user.edit.click

      actual_post_code = dfe.profile.post_code.value
      expect(actual_post_code).to eq(expected_post_code)
    end

    it 'then the ofsted nuumber alone is updated when requested' do
      expected_ofsted_number = Faker::Number.number(digits: 10).to_s
      dfe.profile.ofsted_number.set expected_ofsted_number
      dfe.profile.update_button.click

      dfe.user.displayed?(5)
      dfe.user.wait_until_edit_visible
      dfe.user.edit.click

      actual_ofsted_number = dfe.profile.ofsted_number.value
      expect(actual_ofsted_number).to eq(expected_ofsted_number)
    end

    it 'then the changes to the first name, last name, postcode and ofsted number occurs' do
      expected_first_name = Faker::Name.first_name
      expected_last_name = Faker::Name.last_name
      expected_post_code = Faker::Address.postcode
      expected_ofsted_number = Faker::Number.number(digits: 10).to_s

      dfe.profile.first_name.set expected_first_name
      dfe.profile.last_name.set expected_last_name
      dfe.profile.post_code.set expected_post_code
      dfe.profile.ofsted_number.set expected_ofsted_number

      dfe.profile.update_button.click

      dfe.user.displayed?(5)
      dfe.user.wait_until_edit_visible
      dfe.user.edit.click

      actual_first_name = dfe.profile.first_name.value
      actual_last_name = dfe.profile.last_name.value
      actual_post_code = dfe.profile.post_code.value
      actual_ofsted_number = dfe.profile.ofsted_number.value

      expect(actual_first_name).to eq(expected_first_name)
      expect(actual_last_name).to eq(expected_last_name)
      expect(actual_post_code).to eq(expected_post_code)
      expect(actual_ofsted_number).to eq(expected_ofsted_number)
    end
  end
end
