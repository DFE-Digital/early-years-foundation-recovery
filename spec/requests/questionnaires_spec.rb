require 'rails_helper'

RSpec.describe "Questionnaires", type: :request do
  describe "GET /show" do
    it "returns http success" do
      get "/questionnaires/show"
      expect(response).to have_http_status(:success)
    end
  end

end
