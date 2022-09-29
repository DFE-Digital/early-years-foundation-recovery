require 'rails_helper'

RSpec.describe 'Registered user sign in', type: :system do
  include_context 'with user'

  context 'when successful' do
    it 'returns to the "My modules" page' do
      expect(page).to have_current_path '/my-modules'
      expect(page).to have_text('Signed in successfully').and have_text('My modules')
    end
  end
end
