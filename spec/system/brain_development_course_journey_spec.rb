require 'rails_helper'

RSpec.describe 'Brain Development training registered user' do
  context 'when registered user' do
    let(:user) { create :user, :registered }

    before do
      visit '/users/sign_in'
      fill_in 'Email address', with: user.email
      fill_in 'Password', with: 'StrongPassword123'
      click_button 'Sign in'
    end

    specify 'good path journey' do
      click_link 'Training Modules'
      click_link 'Brain development in early years'

      expect(page).to have_text('Brain development in the early years') # 1 Module intro page
      click_link 'Next' # go to 1-1 Sub-module into page
      click_link 'Next' # go to 1-1-1 Topic intro page
      click_link 'Next' # go to 1-1-1-1a Learning content page
      click_link 'Next' # go to 1-1-1-1b Formative assessment

      expect(page).to have_text('How many areas of the brain are there?')
      choose '5'
      click_button 'Next' # to see assessment_summary
      expect(page).to have_text("That's right")
      click_link 'Next' # go to 1-1-1-2a Learning content page

      click_link 'Next' # go to 1-1-1-2b Formative assessment

      expect(page).to have_text("In which trimester does the baby's brain triple in weight?")
      choose '3'
      click_button 'Next' # to see assessment_summary
      expect(page).to have_text("That's right")
      click_link 'Next' # go to 1-1-1-3a Learning content page

      click_link 'Next' # go to 1-1-1-3b Formative assessment
      expect(page).to have_text('Premature birth, low birth weight and underdeveloped brain, might be due to which influence?')
    end
  end
end
