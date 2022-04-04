# frozen_string_literal: true

require_relative '../uat_helper'

describe 'Edit Profile' do
  let(:dfe) { Dfe.new }
  # let(:home) { Pages::Home.new }
  # let(:sign_in) { Pages::SignIn.new }
  # let(:profile) { Pages::Profile.new }

  before { dfe.home.load }

  context 'for an existing user' do
    it 'updates the first name alone when requested', {wiper: true} do
      # puts 'hi'
      # home.header.sign_in.click
      # sign_in.wait_until_header_visible
      # sign_in.email.set ENV['EMAIL']
      # sign_in.password.set ENV['PASS']
      # sign_in.sign_in_button.click
      #
      #
      sleep 2
    end

    it 'updates the last name alone when requested'
    it 'updates the postcode alone when requested'
    it 'changes the ofsted number alone when requested'
    it 'changes the first, last, postcode, ofted number when all are required for an update'
  end
end
