require 'rails_helper'

RSpec.describe 'Static page', type: :request do
  specify { expect('/accessibility-statement').to be_successful }

  specify { expect('/cookie-policy').to be_successful }

  specify { expect('/new-registration').to be_successful }

  specify { expect('/other-problems-signing-in').to be_successful }

  specify { expect('/privacy-policy').to be_successful }

  specify { expect('/terms-and-conditions').to be_successful }

  specify { expect('/users/timeout').to be_successful }

  specify { expect('/wifi-and-data').to be_successful }

  specify { expect('/whats-new').to be_successful }

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
