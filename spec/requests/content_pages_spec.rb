require 'rails_helper'

RSpec.describe 'ContentPages', type: :request do
  include_context 'with progress'

  before do
    sign_in user
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

  describe 'GET /modules/:training_module_id/content-pages/1-3-4' do
    before do
      get training_module_content_page_path(:alpha, '1-3-4')
    end

    context 'when module is not completed' do
      it 'shows not completed' do
        expect(response.body).to include('You have not yet completed the module.')
      end

      it 'does not have the users name' do
        expect(response.body).not_to include(user.first_name)
        expect(response.body).not_to include(user.last_name)
      end
    end

    context 'when module is completed' do
      before do
        view_whole_module(alpha)
        get training_module_content_page_path(:alpha, '1-3-4')
      end

      it 'shows completed' do
        expect(response.body).to include('Congratulations! You have now completed this module.')
      end

      it "has the user's name" do
        expect(response.body).to include(user.first_name)
        expect(response.body).to include(user.last_name)
      end
    end
  end
end
