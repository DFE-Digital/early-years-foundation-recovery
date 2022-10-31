require 'rails_helper'

RSpec.describe 'TrainingModules', type: :request do
  describe 'GET /about-training' do
    let(:published_modules) { TrainingModule.published }

    before do
      sign_in create(:user, :registered)
      get course_overview_path
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'omits draft modules' do
      expect(response.body).not_to include('delta')
    end
  end
end
