require 'rails_helper'

RSpec.describe Training::ResponsesController, type: :controller do
  before do
    skip 'WIP' unless Rails.application.cms?
    sign_in create(:user, :registered)
  end

  it '#show' do
    get :show, params: { training_module_id: 'alpha', id: '1-1-4' }
    expect(response).to have_http_status(:success)
  end

  context '#update' do
    let(:page) { { training_module_id: 'alpha', id: '1-1-4' } }

    it 'with correct answer' do
      page_params = page.merge(response: { answer: "1" } )
      patch :update, params: page_params 
      expect(response).to have_http_status(:success)
    end

    it 'with incorrect answer' do
      page_params = page.merge(response: { answer: "2" } )
      patch :update, params: page_params 
      expect(response).to have_http_status(:success)
    end

    it 'with blank answer' do
      page_params = page.merge(response: { answer: nil } )
      patch :update, params: page_params 
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end