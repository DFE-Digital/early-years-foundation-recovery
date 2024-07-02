require 'rails_helper'

RSpec.describe 'Feedback' do
  before do
    visit '/'
  end

  describe 'in beta banner' do
    specify do
      within '.govuk-phase-banner' do
        expect(page).to have_text 'This is a new service, your feedback will help us improve it.'
        expect(page).to have_link 'feedback', href: '/feedback'
      end
    end
  end

  describe 'in footer' do
    specify do
      within '.govuk-footer' do
        expect(page).to have_link 'Feedback', href: '/feedback'
      end
    end
  end
end
