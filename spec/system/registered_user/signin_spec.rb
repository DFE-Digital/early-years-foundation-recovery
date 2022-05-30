require 'rails_helper'

RSpec.describe 'Registered user sign in', type: :system do
  include_context 'with user'

  context 'when successful' do
    it 'returns to homepage' do
      expect(page).to have_current_path '/'
      expect(page).to have_text('Signed in successfully')
        .and have_text('Child development training for early years providers')
    end
  end
end
