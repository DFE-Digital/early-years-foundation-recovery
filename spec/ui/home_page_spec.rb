# frozen_string_literal: true

require_relative '../ui_auto_helper'

describe 'Dfe' do
  context 'when on the homepage' do
    let(:home_page) { Pages::Home.new }
    let(:sign_in) { Pages::SignIn.new }

    it 'clicking the homepage logo redirects to the homepage' do
      home_page.load
      home_page.header.logo.click

      expect(home_page).to be_displayed
    end

    it 'clicking the sign link navigates away from the home page' do
      home_page.load
      home_page.header.sign_in.click
      sign_in.wait_until_header_visible

      expect(sign_in).to be_displayed
    end
  end
end
