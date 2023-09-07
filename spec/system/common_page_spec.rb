require 'rails_helper'

RSpec.describe 'Common page' do
  include_context 'with user'

  before { visit(common_page) }

  describe 'assessment intro' do
    subject(:common_page) { '/modules/alpha/content-pages/1-3-2' }

    it 'uses generic content' do
      expect(page).to have_content 'End of module test'
    end

    it 'includes the module assessment passmark' do
      expect(page).to have_content 'If you do not score 70%, you will be able to see which questions you got wrong.'
    end
  end

  describe 'confidence intro' do
    subject(:common_page) { '/modules/alpha/content-pages/1-3-3' }

    it 'uses generic content' do
      expect(page).to have_content 'Reflect on your learning'
      expect(page).to have_content 'To help DfE to measure our impact, please answer the following questions.'
    end
  end

  describe 'thank you' do
    subject(:common_page) { '/modules/alpha/content-pages/1-3-3-5' }

    it 'uses generic content' do
      expect(page).to have_content 'Thank you'
      expect(page).to have_content 'You can also give feedback about the training'
    end

    it 'includes a link to a module specific feedback form' do
      expect(page).to have_link 'give feedback about the training (opens in new window)', href: 'https://forms.office.com/Pages/ResponsePage.aspx?id=xxxxx'
    end
  end
end
