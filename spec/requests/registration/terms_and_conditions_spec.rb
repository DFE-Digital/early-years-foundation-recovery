require 'rails_helper'

RSpec.describe 'Registration names', type: :request do
  subject(:user) { create(:user, :confirmed) }

  before do
    sign_in user
  end

  describe 'GET /registration/terms_and_conditions/edit' do
    it 'returns http success' do
      get edit_registration_name_path
      expect(response).to have_http_status(:success)
    end
  end
end
