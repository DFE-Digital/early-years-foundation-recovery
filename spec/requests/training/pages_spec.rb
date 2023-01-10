require 'rails_helper'

RSpec.describe 'Pages', type: :request do
  include_context 'with progress'

  before do
    sign_in user
  end

  describe 'GET /modules/:training_module_id/content-pages' do
    before do
      get '/modules/alpha/content-pages'
    end

    let(:page_id) do
      'what-to-expect'
    end

    it 'redirects to first item' do
      expect(response).to redirect_to(training_module_content_page_path(:alpha, page_id))
    end
  end
end
