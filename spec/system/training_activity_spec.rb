require 'rails_helper'

RSpec.describe 'User module progress on training overview', type: :system do
  include_context 'with user'

  before do
    visit '/my-learning'
  end

  it 'has sections' do
    within '#started' do
      expect(page).to have_text('In progress')
        .and have_text('You have not started any modules. To begin the training course, start an available module.')
    end
  end
end
