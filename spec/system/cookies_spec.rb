require 'rails_helper'

RSpec.describe 'Selecting cookie options' do
  let(:track_analytics_cookie) { get_me_the_cookie('track_analytics')[:value] }

  context 'when I am a visitor that has not selected their cookie options' do
    before do
      visit root_path
    end

    it 'display cookie banner' do
      expect(page).to have_content('Cookies on Child development training')
    end

    context 'when cookie banner is displayed' do
      it 'visitor can click to read cookie policy' do
        click_on 'Read the cookie policy'
        expect(page).to have_content('Cookies')
          .and have_current_path('/settings/cookie-policy')
      end

      it 'visitor can click to accept analytics cookies' do
        click_on 'Accept analytics cookies'
        expect(track_analytics_cookie).to eq 'true'
        expect(page).not_to have_content('Cookies on Child development training')
      end

      it 'visitor can click to reject analytics cookies' do
        click_on 'Reject analytics cookies'
        expect(track_analytics_cookie).to eq 'false'
        expect(page).not_to have_content('Cookies on Child development training')
      end
    end
  end

  context 'when I am a visitor that has rejected cookie option and visit cookie page' do
    before do
      cookies[:track_analytics] = 'false'
      visit setting_path('cookie-policy')
    end

    it 'visitor can change cookie choice to accept cookies' do
      choose('Yes')
      click_on 'Save cookie settings'

      expect(track_analytics_cookie).to eq 'true'
    end
  end

  context 'when I am a visitor that has accepted cookie option and visit cookie page' do
    before do
      cookies[:track_analytics] = 'Yes'
      visit setting_path('cookie-policy')
    end

    it 'visitor can change cookie choice to reject cookies' do
      choose('No')
      click_on 'Save cookie settings'

      expect(track_analytics_cookie).to eq 'false'
    end
  end
end
