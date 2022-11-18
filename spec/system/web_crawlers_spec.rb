require 'rails_helper'

RSpec.describe 'Web crawlers' do
  include_context 'with user'

  context 'when not in production environment' do
    it 'displays meta tag' do
      visit '/'
      expect(page.body).to include('noindex,nofollow')
    end
  end

  context 'when in production environment' do
    before do
      allow(Rails).to receive(:env) { 'production'.inquiry }
    end

    it 'does not display meta tag' do
      visit '/'
      expect(page.body).not_to include('noindex,nofollow')
    end
  end
end
