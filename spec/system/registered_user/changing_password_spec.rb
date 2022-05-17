require 'rails_helper'

RSpec.describe 'Registered user changing password', type: :system do
  let(:user) { create :user, :registered }
  
  before do
    visit '/users/sign_in'
    fill_in 'Email address', with: user.email
    fill_in 'Password', with: 'StrongPassword123'
    click_button 'Sign in'
  end

  it 'is successful' do
    expect(page).to have_text('Signed in successfully')
      .and have_text('Child development training for early years providers') # home page
  end
end
