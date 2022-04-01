require 'rails_helper'

RSpec.describe 'Static', type: :request do
  describe 'GET static/terms_and_conditions' do
    it 'renders successfully' do
      get static_path(:terms_and_conditions)
      expect(response).to have_http_status(:success)
    end
  end
end
