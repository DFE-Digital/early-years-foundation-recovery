require 'rails_helper'

RSpec.describe "ContentPages", type: :request do
  before do
    sign_in create(:user, :registered)
  end

  describe "GET /modules/:training_module_id/content_pages" do
    let(:first_module_item) { ModuleItem.where(training_module: :test).first }

    it "redirects to first item" do
      get training_module_content_pages_path(:test)
      expect(response).to redirect_to(training_module_content_page_path(:test, first_module_item))
    end
  end

  describe "GET /modules/:training_module_id/content_pages/:id" do
    let(:module_item) { ModuleItem.find_by(training_module: :test, type: :text_page) }

    it "renders a template successfully" do
      get training_module_content_page_path(:test, module_item.id)
      expect(response).to have_http_status(:success)
    end

    context "when module item is a questionnaire" do
      let(:module_item) { ModuleItem.find_by(training_module: :test, type: :formative_assessment) }

      it "redirects to questionnaire controller" do
        get training_module_content_page_path(:test, module_item.id)
        expect(response).to redirect_to(training_module_questionnaire_path(:test, module_item.model))
      end
    end
  end
end
