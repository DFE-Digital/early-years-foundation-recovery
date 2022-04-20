# frozen_string_literal: true

require_relative './spec_helper'

describe 'home page' do
  context 'when unauthenticated' do
    let(:ui) { Ui.new }

    before { ui.home.load }

    after do
      browser = Capybara.current_session.driver.browser
      browser.manage.delete_all_cookies
    end

    it 'is displayed when the user navigates to the home page and clicks the header logo' do
      ui.home.header.logo.click

      expect(ui.home).to be_displayed
    end

    it 'navigates away from the home page when the user clicks sign in' do
      ui.home.header.sign_in.click

      ui.sign_in.wait_until_header_visible

      expect(ui.sign_in).to be_displayed
    end
  end
end
