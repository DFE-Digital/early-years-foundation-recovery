RSpec.shared_context 'with user' do
  let(:user) { create(:user, :registered, :emails_opt_in) }

  before do
    visit '/users/sign-in'
    fill_in 'Email address', with: user.email
    fill_in 'Password', with: 'StrongPassword123'
    click_button 'Sign in'
  end
end
