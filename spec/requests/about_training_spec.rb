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

    it 'counts course modules' do
      expect(response.body).to include('The course has 4 modules.')
      expect(response.body).to include('3 modules are currently available.')
    end
  end
end
