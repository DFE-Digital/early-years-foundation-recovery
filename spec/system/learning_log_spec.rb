require 'rails_helper'

RSpec.describe 'Learning log', type: :system do
  include_context 'with user'
  include_context 'with progress'

  context 'before training starts' do
    describe 'navigation menu' do
      it 'does not show learning log' do
        visit '/'
        expect(page.find('nav')).to_not have_text('Learning log')
      end
    end
  end

  context 'after training starts' do
    before do
      start_first_submodule(alpha)
    end

    it 'shows learning log' do
      pending 'need way to simulate starting module that includes setting module time to completion'
      expect(page.find('nav')).to have_text('Learning log')
    end
  end
end