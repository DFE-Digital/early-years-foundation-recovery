require 'rails_helper'

RSpec.describe 'Timeout modal' do
  context 'with an authenticated user' do
    include_context 'with user'

    it 'data attribute user status' do
      visit '/my-modules'
      expect(page).to have_selector("#js-timeout-warning[@data-user-status='true']")
    end

    it 'data attribute minutes modal to popup to user after no activity' do
      visit '/my-modules'
      expect(page).to have_selector('#js-timeout-warning[@data-minutes-idle-timeout]')
    end

    it 'data attribute minutes modal to be displayed to user' do
      visit '/my-modules'
      expect(page).to have_selector('#js-timeout-warning[@data-minutes-modal-visible]')
    end

    it 'data attributes timeout modal combined should be less than user_timeout_minutes' do
      visit '/my-modules'
      data_minutes_idle_timeout = page.find('#js-timeout-warning')['data-minutes-idle-timeout']
      data_minutes_modal_visible = page.find('#js-timeout-warning')['data-minutes-modal-visible']
      expect(Rails.configuration.user_timeout_minutes).to be >= (data_minutes_idle_timeout.to_i + data_minutes_modal_visible.to_i)
    end
  end

  context 'with an unauthenticated user' do
    it 'data attribute user status' do
      visit '/'
      expect(page).to have_selector("#js-timeout-warning[@data-user-status='false']")
    end
  end
end
