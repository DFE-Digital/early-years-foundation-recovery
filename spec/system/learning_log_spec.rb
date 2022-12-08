require 'rails_helper'

RSpec.describe 'Learning log', type: :system do
  include_context 'with user'
  include_context 'with progress'

  context 'when training has not started' do
    describe 'navigation menu' do
      it 'does not show learning log' do
        visit '/'
        expect(page.find('nav')).not_to have_text('Learning log')
      end
    end
  end

  context 'when training starts' do
    before do
      start_first_submodule(alpha)
    end

    it 'shows learning log' do
      pending 'need way to simulate starting module that includes setting module time to completion'
      expect(page.find('nav')).to have_text('Learning log')
    end
  end
end
