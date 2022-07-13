require 'rails_helper'

RSpec.describe 'Govspeak', type: :system do
  include_context 'with user'

  context 'with module intro' do
    before do
      visit '/modules/alpha/content-pages/intro'
    end

    it 'is displayed' do
      expect(page.source).to include '<div role="note" aria-label="Warning" class="application-notice help-notice">'
      expect(page).to have_text 'Warning: people like stuff!'
    end
  end

  context 'with formative assessments' do
    before do
      visit '/modules/alpha/formative-assessments/1-2-1-1'
    end

    it 'is displayed' do
      expect(page.source).to include '<div role="note" aria-label="Warning" class="application-notice help-notice">'
      expect(page).to have_text 'Warning: people like stuff!'
    end
  end
end
