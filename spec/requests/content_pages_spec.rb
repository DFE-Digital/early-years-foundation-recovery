require 'rails_helper'

RSpec.describe 'ContentPages', :vcr, type: :request do
  include_context 'with progress'

  before do
    sign_in create(:user, :registered)
  end

  describe 'GET /modules/:training_module_id/content-pages' do
    before do
      get training_module_content_pages_path(:alpha)
    end

    let(:module_item) do
      ModuleItem.where(training_module: :alpha).first
    end

    it 'redirects to first item' do
      expect(response).to redirect_to(training_module_content_page_path(:alpha, module_item))
    end
  end

  describe 'GET /modules/:training_module_id/content-pages/:id' do
    before do
      get training_module_content_page_path(:alpha, module_item)
    end

    context 'when module item is a text content page' do
      let(:module_item) do
        ModuleItem.where(training_module: :alpha, type: :text_page).first
      end

      it 'renders a template successfully' do
        expect(response).to have_http_status(:success)
      end
    end

    context 'when module item is a question' do
      let(:module_item) do
        ModuleItem.where(training_module: :alpha, type: :formative_questionnaire).first
      end

      it 'redirects to questionnaire controller' do
        expect(response).to redirect_to(training_module_questionnaire_path(:alpha, module_item.model))
      end
    end
  end
end
