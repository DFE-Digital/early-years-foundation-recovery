# frozen_string_literal: true
require_relative './spec_helper'

describe 'Create Account' do
  let(:ui) { Ui.new }
  let(:password) { Faker::Internet.password(min_length: 8, max_length: 10) }

  before do
    ui.home.load
    ui.home.header.sign_in.click
  end

  context 'when required mandatory details are provided' do
    it 'then the email confirmation message is displayed' do
      expected_message = 'success'
      ui.sign_in.displayed?(5)
      ui.sign_in.create_account.click

      ui.sign_up.displayed?(5)
      ui.sign_up.wait_until_email_visible
      ui.sign_up.email.set Faker::Internet.email
      ui.sign_up.password.set password
      ui.sign_up.confirm_password.set password
      ui.sign_up.continue.click

      ui.home.displayed?(200)
      expect(ui.home.has_success_banner_title?).to be true
      expect(ui.home.success_banner_title.text.strip.downcase).to eq expected_message
    end
  end
end