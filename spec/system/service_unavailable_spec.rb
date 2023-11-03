require 'rails_helper'

RSpec.describe 'Service Unavailable' do
  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('MAINTENANCE').and_return('true')
  end

  context 'when the service is unavailable and user navigates to home' do
    before do
      visit '/service-unavailable'
      get '/'
    end

    it 'redirects to the service unavailable page' do
      expect(response).to redirect_to '/service-unavailable'
    end

    it 'the page has the correct content' do
      expect(page).to have_css('h1', text: 'Sorry, the service is unavailable')
      expect(page).to have_title('Early years child development training : Sorry, the service is unavailable')
    end
  end

  context 'when the service is unavailable and user navigates to my modules page' do
    before do
      get my_modules_path
    end

    it 'redirects to the service unavailable page' do
      expect(response).to redirect_to '/service-unavailable'
    end
  end

  context 'when the service is unavailable and user is already on the service unavailable page' do
    before do
      get '/service-unavailable'
    end

    it 'does not redirect to the user' do
      expect(response).not_to have_http_status(:redirect)
    end
  end
end
