require 'rails_helper'

RSpec.describe 'Service Unavailable' do
  let(:user) { create :user }

  context 'when the service is unavailable' do
    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('SERVICE_UNAVAILABLE').and_return('true')
      visit '/'
    end

    it 'redirects to the service unavailable page' do
      expect(page).to have_text('Sorry, the service is unavailable')
    end
  end
end
