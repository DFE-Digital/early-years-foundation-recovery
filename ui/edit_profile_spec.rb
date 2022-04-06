# frozen_string_literal: true

require_relative '../uat_helper'

describe 'Edit Profile' do
  # let(:dfe) { Dfe.new }
  let(:home) { Pages::Home.new }
  let(:sign_in) { Pages::SignIn.new }
  let(:profile) { Pages::Profile.new }
  let(:user) { Pages::User.new }

  before(:each) do
    home.load
    home.header.sign_in.click
    sign_in.wait_until_header_visible
    sign_in.email.set ENV['EMAIL']
    sign_in.password.set ENV['PASS']
    sign_in.sign_in_button.click

    home.header.profile.click

    profile.displayed?
    profile.wait_until_first_name_visible
  end

  after(:each) do
    # Capybara.current_session.driver.quit
    browser = Capybara.current_session.driver.browser
    browser.manage.delete_all_cookies
  end

  context 'when an existing user' do
    it 'then the first name alone is updated when requested' do

      expected_first_name = Faker::Name.first_name
      profile.first_name.set expected_first_name
      profile.update.click

      user.displayed?
      user.wait_until_edit_visible
      user.edit.click

      actual_first_name = profile.first_name.value
      expect(actual_first_name).to eq(expected_first_name)
    end

    it 'then the last name alone is updated when requested' do
      expected_last_name = Faker::Name.last_name
      profile.last_name.set expected_last_name
      profile.update.click

      user.displayed?
      user.wait_until_edit_visible
      user.edit.click

      actual_last_name = profile.last_name.value
      expect(actual_last_name).to eq(expected_last_name)
    end

    it 'then the postcode alone is updated when requested' do
      fail
    end

    it 'then the ofsted nuumber alone is updated when requested'
    it 'then the changes to the first, last, postcode and ofsted number are updated when requested'
  end
end
