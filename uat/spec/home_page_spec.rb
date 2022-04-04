# frozen_string_literal: true

require_relative '../uat_helper'

describe 'home_page' do
  context 'when unauthenticated' do
    let(:home_page) { Pages::Home.new }
    let(:sign_in) { Pages::SignIn.new }

    before { home_page.load }

    it 'is displayed when the user navigates to the home page and clicks the header logo' do
      home_page.header.logo.click

      expect(home_page).to be_displayed
    end

    it 'navigates away from the home page when the user clicks sign in' do
      home_page.header.sign_in.click

      sign_in.wait_until_header_visible

      expect(sign_in).to be_displayed
    end
  end
end
