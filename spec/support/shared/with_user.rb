RSpec.shared_context 'with user' do
  if Rails.application.gov_one_login?
    let(:user) { create(:gov_one_user) }

    before do
      sign_in user
      visit '/users/sign-in'
    end

  else
    let(:user) { create(:user, :registered) }

    before do
      visit '/users/sign-in'
      fill_in 'Email address', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Sign in'
    end
  end
end
