require 'rails_helper'

RSpec.describe 'Registration research participation', type: :request do
  subject(:user) do
    create :user, :named,
           setting_type_id: Trainee::Setting.all.sample.name,
           role_type: Trainee::Role.all.sample.name
  end

  before { sign_in user }

  describe 'GET /registration/research-participant/edit' do
    it 'returns http success' do
      get edit_registration_research_participant_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH /registration/research-participant' do
    let(:update_user) do
      patch registration_research_participant_path, params: {
        user: {
          research_participant: true,
        },
      }
    end

    context 'when opting in' do
      it 'updates the research preference' do
        expect { update_user }.to change { user.reload.research_participant }.to(true)
      end

      it 'redirects to the check your answers page' do
        update_user
        expect(response).to redirect_to edit_registration_check_your_answers_path
      end
    end
  end
end
