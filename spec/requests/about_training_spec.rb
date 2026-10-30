require 'rails_helper'

RSpec.describe 'About training', type: :request do
  describe 'GET /about-training' do
    before do
      get course_overview_path
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'omits draft modules' do
      expect(response.body).not_to include('delta')
    end

    it 'counts only live course modules' do
      live_module_count = Training::Module.live.count

      expect(response.body).to include(
        "The course has #{live_module_count} modules",
      )
    end
  end
end
