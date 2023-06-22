require 'rails_helper'

RSpec.describe 'Feedback form' do
  before do
    visit '/'
  end

  let(:feedback_url) { Rails.configuration.feedback_url }

  describe 'in beta banner' do
    specify do
      within '.govuk-phase-banner' do
        expect(page).to have_text 'This is a new service, your feedback will help us improve it.'
        expect(page).to have_link 'feedback', href: feedback_url
      end
    end
  end

  describe 'in footer' do
    specify do
      within '.govuk-footer' do
        expect(page).to have_link 'Feedback', href: feedback_url
      end
    end
  end
end
