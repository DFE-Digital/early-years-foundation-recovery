require 'rails_helper'

RSpec.describe 'End of module feedback form' do
  include_context 'with progress'
  include_context 'with user'

  it do
    visit '/modules/alpha/questionnaires/feedback2'
    expect(page).to have_content('Did the module meet your expectations')
    expect(page).to have_content('Yes')
  end
end
