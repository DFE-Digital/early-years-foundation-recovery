require 'rails_helper'

RSpec.describe 'Static page', type: :request do
  specify { expect('/terms-and-conditions').to be_successful }

  specify { expect('/accessibility-statement').to be_successful }

  specify { expect('/privacy-policy').to be_successful }

  specify { expect('/users/timeout').to be_successful }

  context 'with errors' do
    specify do
      get '/404'
      expect(response).to have_http_status(:not_found)
    end

    specify do
      get '/500'
      expect(response).to have_http_status(:internal_server_error)
    end
  end
end
