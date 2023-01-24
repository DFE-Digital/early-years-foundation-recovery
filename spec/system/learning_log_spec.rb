require 'rails_helper'

RSpec.describe 'Learning log' do
  include_context 'with user'
  include_context 'with progress'

  describe 'navigation menu' do
    context 'when training has not started' do
      before do
        visit '/'
      end

      it 'does not show learning log' do
        expect(page.find('nav')).not_to have_text 'Learning log'
      end
    end
  end

  context 'when training starts' do
    before do
      start_first_submodule(alpha)
      visit '/'
    end

    it 'shows learning log' do
      expect(page.find('nav')).to have_text 'Learning log'
    end
  end
end
