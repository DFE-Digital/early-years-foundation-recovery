require 'rails_helper'

RSpec.describe 'Web crawlers' do
  context 'when not in production environment' do
    it 'displays meta tag' do
      visit '/'
      expect(page.body).to include('noindex,nofollow')
    end
  end

  context 'when in production environment' do
    before do
      ENV['WORKSPACE'] = 'production'
    end

    it 'does not display meta tag' do
      visit '/'
      expect(page.body).not_to include('noindex,nofollow')
    end
  end
end
