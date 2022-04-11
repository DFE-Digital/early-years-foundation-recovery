# frozen_string_literal: true

require_relative './spec_helper'

describe 'home_page' do
  context 'when unauthenticated' do
    let(:dfe) { Dfe.new }

    before { home_page.load }

    it 'is displayed when the user navigates to the home page and clicks the header logo' do
      dfe.home_page.header.logo.click

      expect(dfe.home_page).to be_displayed
    end

    it 'navigates away from the home page when the user clicks sign in' do
      dfe.home_page.header.sign_in.click

      dfe.sign_in.wait_until_header_visible

      expect(dfe.sign_in).to be_displayed
    end
  end
end
