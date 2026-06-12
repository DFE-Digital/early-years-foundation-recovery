require 'rails_helper'

RSpec.describe 'Registration where you live', type: :request do
  subject(:user) do
    create :user, :confirmed
  end

  before { sign_in user }

  describe 'GET /registration/where_you_live/edit' do
    it 'returns http success' do
      get edit_registration_where_you_live_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH /registration/where_you_live' do
    let(:update_user) do
      patch registration_where_you_live_path, params: {
        user: {
          where_you_live: where_you_live,
        },
      }
    end

    context 'with available option' do
      let(:where_you_live) { 'England' }

      it 'Updates where you live value' do
        expect { update_user }.to change { user.reload.country }.to(where_you_live)
      end

      it 'redirects to setting type form' do
        update_user
        expect(response).to redirect_to edit_registration_setting_type_path
      end
    end

    context 'with lowercase id option' do
      let(:where_you_live) { 'england' }

      it 'stores canonical country value' do
        expect { update_user }.to change { user.reload.country }.to('England')
      end

      it 'redirects to setting type form' do
        update_user
        expect(response).to redirect_to edit_registration_setting_type_path
      end
    end

    context 'with non-England option' do
      let(:where_you_live) { 'Scotland' }

      it 'updates country value' do
        expect { update_user }.to change { user.reload.country }.to(where_you_live)
      end

      it 'redirects to setting type form' do
        update_user
        expect(response).to redirect_to edit_registration_setting_type_path
      end
    end
  end
end
