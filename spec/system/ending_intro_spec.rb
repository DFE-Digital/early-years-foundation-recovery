require 'rails_helper'

RSpec.describe 'Ending' do
  include_context 'with user'

  describe 'intro' do
    it 'uses generic content' do
      visit '/modules/alpha/content-pages/1-3-3-4'
      expect(page).to have_content('Thank you')
        .and have_content('You can also give feedback about the training')
    end
  end
end