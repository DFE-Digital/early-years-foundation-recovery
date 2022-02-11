require 'rails_helper'

RSpec.describe "TrainingModules", type: :request do
  describe "GET /training_modules" do
    let(:training_module) { TrainingModule.first }
    before do
      sign_in create(:user, :registered)
    end

    it "returns http success" do
      get training_modules_path
      expect(response).to have_http_status(:success)
    end

    it "lists training modules" do
      get training_modules_path
      expect(response.body).to include(training_module.title)
    end
  end
end
