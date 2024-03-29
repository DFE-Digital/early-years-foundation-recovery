require 'rails_helper'

RSpec.describe 'New stuff page' do
  include_context 'with user'

  context 'when the feature is disabled' do
    it 'does not redirect' do
      expect(page).not_to have_current_path '/whats-new'
      expect(page).to have_current_path '/my-modules'
    end
  end

  context 'when enabled' do
    let(:user) do
      create :user, :registered, display_whats_new: true
    end

    it 'appears after login' do
      expect(page).to have_current_path '/whats-new'
    end

    describe 'with subsequent logins' do
      before do
        click_on 'sign-out-desktop'
        sign_in user
        visit '/users/sign-in'
      end

      it 'does not appear' do
        expect(page).not_to have_current_path '/whats-new'
        expect(page).to have_current_path '/my-modules'
      end
    end
  end
end
