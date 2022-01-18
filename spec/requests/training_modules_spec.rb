require 'rails_helper'

RSpec.describe "TrainingModules", type: :request do
  describe "GET /training_modules" do
    it "returns http success" do
      get training_modules_path
      expect(response).to have_http_status(:success)
    end
  end
end
