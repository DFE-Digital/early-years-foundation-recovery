require 'rails_helper'

#
# Backend agnostic
#
RSpec.describe 'Static page', :cms, type: :request do
  context 'when public' do
    specify { expect('/accessibility-statement').to be_successful }

    specify { expect('/settings/cookie-policy').to be_successful }

    specify { expect('/new-registration').to be_successful }

    specify { expect('/other-problems-signing-in').to be_successful }

    specify { expect('/privacy-policy').to be_successful }

    specify { expect('/promotional-materials').to be_successful }

    specify { expect('/sitemap').to be_successful }

    specify { expect('/terms-and-conditions').to be_successful }

    specify { expect('/users/timeout').to be_successful }

    specify { expect('/wifi-and-data').to be_successful }
  end

  context 'when authentication is required' do
    specify do
      get '/whats-new'
      expect(response).to have_http_status(:redirect)
    end
  end

  context 'with errors' do
    specify do
      get '/404'
      expect(response).to have_http_status(:not_found)
    end

    specify do
      get '/foo'
      expect(response).to have_http_status(:not_found)
    end

    specify do
      get '/500'
      expect(response).to have_http_status(:internal_server_error)
    end
  end
end
