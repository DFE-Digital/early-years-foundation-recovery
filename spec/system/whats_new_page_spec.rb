require 'rails_helper'

RSpec.describe 'Whats new page', type: :system do
  let(:user) { create :user, :completed, :display_whats_new }
  let(:new_user) { create :user, :completed }

  before do
    visit '/users/sign-in'
  end

  context 'when exisiting user' do
    before do
      fill_in 'Email address', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Sign in'
    end

    context "and 'whats new' page has not been viewed" do
      it "visits what's new page after sign in" do
        expect(page).to have_current_path '/whats-new'
      end
    end

    context "and 'whats new' page has been viewed" do
      let(:user) { create :user, :completed, :display_whats_new }

      it "does not visit what's new page after sign in" do
        click_on 'Sign out'

        visit '/users/sign-in'
        fill_in 'Email address', with: user.email
        fill_in 'Password', with: user.password
        click_button 'Sign in'

        expect(page).not_to have_current_path '/whats_new'
      end
    end
  end

  context 'when new user is created' do
    it "does not visit what's new page" do
      fill_in 'Email address', with: new_user.email
      fill_in 'Password', with: new_user.password
      click_button 'Sign in'

      expect(page).not_to have_current_path '/whats_new'
    end
  end
end
