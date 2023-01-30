require 'rails_helper'

RSpec.describe 'ContentPages', :cms, type: :request do
  before do
    skip 'WIP' unless Rails.application.cms?

    sign_in create(:user, :registered)
  end

  describe 'GET /modules/:training_module_id/content-pages' do
    before do
      get training_module_content_pages_path(:alpha)
    end

    it 'redirects to first item' do
      expect(response).to redirect_to training_module_content_page_path(:alpha, 'what-to-expect')
    end
  end

  describe 'GET /modules/:training_module_id/content-pages/:id' do
    before do
      get training_module_content_page_path(:alpha, page_name)
    end

    context 'when module item is a text content page' do
      let(:page_name) { 'what-to-expect' }

      it 'renders a template successfully' do
        expect(response).to have_http_status(:success)
      end
    end

    context 'when module item is a question' do
      let(:page_name) { '1-1-4' }

      it 'redirects to questionnaire controller' do
        expect(response).to redirect_to training_module_questionnaire_path(:alpha, page_name)
      end
    end
  end
end
