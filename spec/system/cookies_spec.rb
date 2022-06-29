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
      it 'can click to read cookie policy' do
        click_on 'Read the cookie policy'
        expect(page).to have_content('Cookies')
          .and have_current_path('/settings/cookie-policy')
      end

      it 'can click to accept analytics cookies' do
        click_on 'Accept analytics cookies'
        expect(cookies[:track_analytics]).to eq 'No'
        expect(page).not_to have_content('Cookies on Child development training')
      end

      it 'can click to reject analytics cookies' do
        click_on 'Reject analytics cookies'
        expect(cookies[:track_analytics]).to eq 'Yes'
        expect(page).not_to have_content('Cookies on Child development training')
      end
    end
  end

  context 'when I am a visitor that has rejected cookie option and visit cookie page' do
    before do
      cookies[:track_analytics] = 'No'
      visit setting_path('cookie-policy')
    end

    it 'can change cookie choice to accept' do
      choose('Yes')
      click_on 'Save cookie settings'

      expect(cookies[:track_analytics]).to eq 'Yes'
    end
  end

  context 'when I am a visitor that has accepted cookie option and visit cookie page' do
    before do
      cookies[:track_analytics] = 'Yes'
      visit setting_path('cookie-policy')
    end

    it 'can change cookie choice to reject' do
      choose('No')
      click_on 'Save cookie settings'

      expect(cookies[:track_analytics]).to eq 'No'
    end
  end
end
