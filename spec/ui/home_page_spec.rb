# frozen_string_literal: true
require_relative '../ui_auto_helper'

describe Pages::Home do
  context 'Dfe Homepage' do
    let(:home_page) { Pages::Home.new }
    let(:sign_in) { Pages::SignIn.new }

    it 'is displayed when the user navigates to the home page and clicks the header logo' do
      home_page.load
      home_page.header.logo.click

      expect(home_page).to be_displayed
    end

    it 'navigates away from the home page when the user clicks sign in' do
      home_page.load
      home_page.header.sign_in.click

      sign_in.wait_until_header_visible

      expect(sign_in).to be_displayed
    end
  end
end
