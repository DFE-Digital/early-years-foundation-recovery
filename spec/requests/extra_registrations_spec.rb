require 'rails_helper'

RSpec.describe 'ExtraRegistrations', type: :request do
  subject(:user) { create(:user, :confirmed) }

  let(:steps) { ExtraRegistrationsController::STEPS }

  before do
    sign_in user
  end

  describe 'GET /extra_registrations' do
    it 'redirects to first step' do
      get '/extra-registrations'
      expect(response).to redirect_to(edit_extra_registration_path(steps.first))
    end
  end

  describe 'GET /extra_registrations/:id/edit' do
    it 'returns http success' do
      get edit_extra_registration_path(steps.first)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH /extra_registrations/:id' do
    let(:update_user) do
      patch extra_registration_path(step), params: { user: user_params }
    end

    context 'and adds first name to user' do
      let(:step) { :name }
      let(:user_params) do
        {
          first_name: Faker::Name.first_name,
          last_name: Faker::Name.last_name,
        }
      end

      it 'Updates user name' do
        expect { update_user }.to change { user.reload.first_name }.to(user_params[:first_name])
      end

      it 'redirects to next step' do
        next_step = steps[steps.index(step) + 1]
        update_user
        expect(response).to redirect_to(edit_extra_registration_path(next_step))
      end
    end

    context 'when on setting type step' do
      subject(:user) do
        create(:user, :confirmed,
               first_name: Faker::Name.first_name,
               last_name: Faker::Name.last_name)
      end

      let(:step) { :setting }
      let(:user_params) do
        { setting_type: 'other' }
      end

      it 'Updates user setting type' do
        expect { update_user }.to change { user.reload.setting_type }.to(user_params[:setting_type])
      end

      it 'redirects to next step' do
        next_step = steps[steps.index(step) + 1]
        update_user
        expect(response).to redirect_to(edit_extra_registration_path(next_step))
      end
    end
  end
end
