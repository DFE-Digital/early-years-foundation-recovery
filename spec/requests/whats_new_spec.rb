require 'rails_helper'

RSpec.describe "WhatsNews", type: :request do
  describe "GET /whats-new" do
    before do
      sign_in create(:user, :registered)
    end

    describe 'GET /user' do
      it 'renders my account page' do
        get user_path
        expect(response).to have_http_status(:success)
      end
    end
  end
end
