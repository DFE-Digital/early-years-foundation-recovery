require 'rails_helper'

RSpec.describe 'Static page', :cms, type: :request do
  context 'when accessibility statement has moved' do
    before { allow(Rails.configuration).to receive(:accessibility_url).and_return('https://accessibility-statements.education.gov.uk/statement/14') }

    specify do
      get '/accessibility-statement'
      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to('https://accessibility-statements.education.gov.uk/statement/14')
    end

    context 'when ACCESSIBILITY_URL is unset' do
      before { allow(Rails.configuration).to receive(:accessibility_url).and_return('') }

      specify do
        get '/accessibility-statement'
        expect(response).to have_http_status(:moved_permanently)
        expect(response).to redirect_to('/')
      end
    end
  end

  context 'when public' do
    specify { expect('/settings/cookie-policy').to be_successful }

    specify { expect('/new-registration').to be_successful }

    specify { expect('/other-problems-signing-in').to be_successful }

    specify { expect('/promotional-materials').to be_successful }

    specify { expect('/sitemap').to be_successful }

    specify { expect('/terms-and-conditions').to be_successful }

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
