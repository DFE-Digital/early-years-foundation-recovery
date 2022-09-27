require 'rails_helper'

RSpec.describe 'Whats new page' do
  include_context 'with user'

  let(:user) { create :user, :completed, :display_whats_new }
  let(:new_user) { create :user, :completed }

  context 'when exisiting user' do
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
    before do
      user = new_user
    end

    it "does not visit what's new page" do
      expect(page).not_to have_current_path '/whats_new'
    end
  end
end
