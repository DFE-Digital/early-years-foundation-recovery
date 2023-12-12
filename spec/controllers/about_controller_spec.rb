require 'rails_helper'

RSpec.describe AboutController, type: :controller do
  describe 'GET #show' do
    context 'when released' do
      it 'succeeds' do
        get :show, params: { id: 'bravo' }
        expect(response).to have_http_status(:success)
      end
    end

    context 'when not released' do
      it 'redirects' do
        get :show, params: { id: 'delta' }
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe 'GET #experts' do
    it 'succeeds' do
      get :experts
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #course' do
    it 'succeeds' do
      get :course
      expect(response).to have_http_status(:success)
    end
  end
end
