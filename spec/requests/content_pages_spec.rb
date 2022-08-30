require 'rails_helper'

RSpec.describe 'ContentPages', type: :request do
  before do
    sign_in create(:user, :registered, first_name: 'John', last_name: 'Doe')
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

    context 'when module item is a formative question' do
      let(:module_item) do
        ModuleItem.where(training_module: :alpha, type: :formative_questionnaire).first
      end

      it 'redirects to formative assessment controller' do
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
        expect(response.body).not_to include('John Doe')
      end
    end

    context 'when module is completed' do
      include_context 'with progress'

      before do
        view_whole_module(alpha)
      end

      it 'shows completed' do
        pending 'can we mark modules as complete?'
        expect(response.body).to include('Congratulations! You have now completed this module.')
      end

      it 'has the users name' do
        pending 'can we mark modules as complete?'
        expect(response.body).to include('John Doe')
      end
    end
  end
end
