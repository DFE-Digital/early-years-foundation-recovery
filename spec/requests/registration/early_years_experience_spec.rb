require 'rails_helper'

RSpec.describe 'Registration early years experience', type: :request do
  subject(:user) do
    create :user, :confirmed
  end

  before { sign_in user }

  describe 'GET /registration/role_type/edit' do
    it 'returns http success' do
      get edit_registration_early_years_experience_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH /registration/role_type' do
    let(:update_user) do
      patch registration_early_years_experience_path, params: {
        user: {
          early_years_experience: experience,
        },
      }
    end

    context 'with available option' do
      let(:experience) { 'Less than 2 years' }

      it 'Updates user role type' do
        expect { update_user }.to change { user.reload.early_years_experience }.to(experience)
      end

      it 'redirects to training email preference form' do
        update_user
        expect(response).to redirect_to edit_registration_training_emails_path
      end
    end
  end
end
