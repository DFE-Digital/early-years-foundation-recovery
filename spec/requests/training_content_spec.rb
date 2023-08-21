require 'rails_helper'

RSpec.describe 'Training content', type: :request do
  before do
    sign_in create(:user, :registered)
  end

  describe 'GET /modules/:training_module_id/content-pages' do
    before do
      get training_module_pages_path(:alpha)
    end

    it 'redirects to first page' do
      expect(response).to redirect_to training_module_page_path(:alpha, 'what-to-expect')
    end
  end

  describe 'GET /modules/:training_module_id/content-pages/:id' do
    before do
      get training_module_page_path(:alpha, page_name)
    end

    context 'when content is a text page' do
      let(:page_name) { 'what-to-expect' }

      it 'renders a template successfully' do
        expect(response).to have_http_status(:success)
      end
    end

    context 'when content is a question' do
      let(:page_name) { '1-1-4' }

      it 'redirects to questions controller' do
        expect(response).to redirect_to training_module_question_path(:alpha, page_name)
      end
    end
  end
end
