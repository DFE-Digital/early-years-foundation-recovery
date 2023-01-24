require 'rails_helper'

RSpec.describe 'Assessment results page' do
  include_context 'with progress'
  include_context 'with user'

  context 'when on a content page in the first module' do
    before do
      visit 'modules/alpha/assessment-result/1-3-2-5'
    end

    specify do
      expect(page).to have_link 'Back to Module 1 overview', href: '/modules/alpha'
    end
  end

  context 'when on a content page in the second module' do
    before do
      visit 'modules/bravo/assessment-result/1-2-2-1'
    end

    specify do
      expect(page).to have_link 'Back to Module 2 overview', href: '/modules/bravo'
    end
  end
end
