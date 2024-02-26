require 'rails_helper'

RSpec.describe 'Assessment results page' do
  include_context 'with user'

  before do
    create :assessment, :passed, user: user
  end

  describe 'back link' do
    it 'targets the module overview' do
      visit 'modules/alpha/assessment-result/1-3-2-11'
      expect(page).to have_link 'Back to Module 1 overview', href: '/modules/alpha'
    end
  end
end
