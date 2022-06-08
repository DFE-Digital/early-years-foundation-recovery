require 'rails_helper'

RSpec.describe 'Registered user sign in', type: :system do
  include_context 'with user'

  context 'when successful' do
    it 'returns to the "My learning" page' do
      expect(page).to have_current_path '/my-learning'
      expect(page).to have_text('Signed in successfully').and have_text('My learning')
    end
  end
end
