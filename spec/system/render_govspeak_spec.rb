require 'rails_helper'

RSpec.describe '', type: :system do
  let(:user) { create :user, :registered }

  before do
    visit '/users/sign-in'
    fill_in 'Email address', with: user.email
    fill_in 'Password', with: 'StrongPassword123'
    click_button 'Sign in'

    visit 'modules/one/formative-assessments/1-2-2'
  end

  describe 'Govspeak page content' do
    it 'is displayed' do
      expect(page.source).to include '<div role="note" aria-label="Warning" class="application-notice help-notice">'
      expect(page).to have_text 'Warning: people like stuff!'
    end
  end
end
