require 'rails_helper'

RSpec.describe '', type: :system do
  let(:user) { create :user, :registered }

  before do
    visit '/users/sign_in'
    fill_in 'Email address', with: user.email
    fill_in 'Password', with: 'StrongPassword123'
    click_button 'Sign in'

    visit 'modules/one/formative_assessments/1-2-2'
  end

  describe 'Govspeak page content' do
    it 'is displayed' do
      expect(page.source).to include '<div role="note" aria-label="Warning" class="application-notice help-notice">'
      expect(page).to have_text 'Warning: people like stuff!'
    end

    it 'is rendering numbered list' do
      expect(page.source).to include '<ol class="steps">'
    end

    it 'is rendering quotes' do
      expect(page).to have_text '‘ write content here ’'
    end

    it 'is rendering quotes' do
      expect(page).to have_text '‘ write content here ’'
    end

    it 'is rendering callout' do
      expect(page.source).to include '<div class="example">'
      expect(page).to have_text 'Open the pod bay doors'
    end

    it 'is rendering statistic headline' do
      expect(page.source).to include '<div class="stat-headline">'
      expect(page).to have_text '13.8bn'
    end

    it 'is rendering place box' do
      expect(page.source).to include '<div class="place">'
      expect(page).to have_text '13.8bn'
    end

    describe 'Govspeak Contact markdown' do
      it 'is rendering contact' do
        expect(page.source).to include '<div class="contact">'
        expect(page.source).to include '<strong>Student Finance England</strong>'
      end

      it 'is rendering Address' do
        expect(page.source).to include '<div class="address">'
        expect(page.source).to include '<div class="adr org fn">'
        expect(page).to have_text 'Hercules House'
      end
    end

  end
end
