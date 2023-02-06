require 'rails_helper'

RSpec.describe 'Content page' do
  include_context 'with progress'
  include_context 'with user'

  context 'when on a content page in the first module' do
    before do
      start_module(alpha)
      visit 'modules/alpha/content-pages/1-1'
    end

    specify do
      expect(page).to have_link 'Back to Module 1 overview', href: '/modules/alpha'
    end
  end

  context 'when on a content page in the second module' do
    before do
      start_module(bravo)
      visit 'modules/bravo/content-pages/1-1'
    end

    specify do
      expect(page).to have_link 'Back to Module 2 overview', href: '/modules/bravo'
    end
  end
end
