require 'rails_helper'

RSpec.describe 'Timeout modal', type: :system do
  context 'with an authenticated user' do
    include_context 'with user'

    before do
      visit '/my-modules'
    end

    context 'and javascript enabled ' do
      it 'data attribute user status' do
        expect(page).to have_selector("#js-timeout-warning[@data-user-status='true']")
      end

      it 'data attribute minutes modal to popup to user after no activity' do
        expect(page).to have_selector('#js-timeout-warning[@data-minutes-idle-timeout]')
      end

      it 'data attribute minutes modal to be displayed to user' do
        expect(page).to have_selector('#js-timeout-warning[@data-minutes-modal-visible]')
      end

      it 'data attributes timeout modal combined should be less than user_timeout_minutes' do
        data_minutes_idle_timeout = page.find('#js-timeout-warning')['data-minutes-idle-timeout']
        data_minutes_modal_visible = page.find('#js-timeout-warning')['data-minutes-modal-visible']
        expect(Rails.configuration.user_timeout_minutes).to be >= (data_minutes_idle_timeout.to_i + data_minutes_modal_visible.to_i)
      end
    end

    context 'and javascript disabled', js: false do
      it 'does displays a static message on the page' do
        expect(page).to have_content 'For security, you’ll be signed out after 3 minutes of activity.'
      end
    end
  end

  context 'with an unauthenticated user' do
    before do
      visit '/'
    end

    context 'and javascript enabled' do
      it 'data attribute user status' do
        expect(page).to have_selector("#js-timeout-warning[@data-user-status='false']")
      end
    end

    context 'and javascript disabled' do
      it 'does not display the message', js: false do
        expect(page).not_to have_content 'For security, you’ll be signed out after 3 minutes of activity.'
      end
    end
  end
end
