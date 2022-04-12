# frozen_string_literal: true

require_relative './spec_helper'

describe 'home_page' do
  context 'when unauthenticated' do
    let(:dfe) { Dfe.new }

    before { dfe.home.load }

    after do
      browser = Capybara.current_session.driver.browser
      browser.manage.delete_all_cookies
    end

    it 'is displayed when the user navigates to the home page and clicks the header logo' do
      dfe.home.header.logo.click

      expect(dfe.home).to be_displayed
    end

    it 'navigates away from the home page when the user clicks sign in' do
      dfe.home.header.sign_in.click

      dfe.sign_in.wait_until_header_visible

      expect(dfe.sign_in).to be_displayed
    end
  end
end
