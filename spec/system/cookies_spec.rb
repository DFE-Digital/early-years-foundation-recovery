require 'rails_helper'

RSpec.describe 'Selecting cookie options' do
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
        pending 're-enable when new show_me_the_cookies gem is available (6.0.0)'
        click_on 'Accept analytics cookies'
        expect(get_me_the_cookie('track_analytics')[:value]).to eq 'Yes'
        expect(page).not_to have_content('Cookies on Child development training')
      end

      it 'visitor can click to reject analytics cookies' do
        pending 're-enable when new show_me_the_cookies gem is available (6.0.0)'
        click_on 'Reject analytics cookies'
        expect(get_me_the_cookie('track_analytics')[:value]).to eq 'No'
        expect(page).not_to have_content('Cookies on Child development training')
      end
    end
  end

  context 'when I am a visitor that has rejected cookie option and visit cookie page' do
    before do
      cookies[:track_analytics] = 'No'
      visit setting_path('cookie-policy')
    end

    it 'visitor can change cookie choice to accept cookies' do
      pending 're-enable when new show_me_the_cookies gem is available (6.0.0)'
      choose('Yes')
      click_on 'Save cookie settings'

      expect(get_me_the_cookie('track_analytics')[:value]).to eq 'Yes'
    end
  end

  context 'when I am a visitor that has accepted cookie option and visit cookie page' do
    before do
      cookies[:track_analytics] = 'Yes'
      visit setting_path('cookie-policy')
    end

    it 'visitor can change cookie choice to reject cookies' do
      pending 're-enable when new show_me_the_cookies gem is available (6.0.0)'
      choose('No')
      click_on 'Save cookie settings'

      expect(get_me_the_cookie('track_analytics')[:value]).to eq 'No'
    end
  end
end
