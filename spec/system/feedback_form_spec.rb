require 'rails_helper'

RSpec.describe 'Accessing feedback form', type: :system do
  context 'when a visitor wants to access the feedback form' do
    it 'provides link to feedback form in beta banner' do
      visit '/'
      expect(page).to have_link 'feedback', href: Rails.configuration.feedback_url
    end

    it 'provides link to feedback form in footer' do
      visit '/'
      expect(page).to have_link 'Feedback', href: Rails.configuration.feedback_url
    end
  end
end
