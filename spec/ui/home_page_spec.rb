# frozen_string_literal: true

describe Pages::Home do
  context 'Dfe Homepage' do
    before(:each) do
      @home_page = Pages::Home.new
    end

    it 'Should be displayed when the user navigates to the hame page and clicks the header logo' do
      @home_page.load
      @home_page.header.logo.click

      expect(@home_page).to be_displayed
    end

    it 'should navigate away from the home page when the user clicks sign in' do
      @home_page.load
      @home_page.header.sign_in.click
      @sign_in = Pages::SignIn.new
      @sign_in.wait_until_header_visible

      expect(@sign_in).to be_displayed
    end
  end
end
