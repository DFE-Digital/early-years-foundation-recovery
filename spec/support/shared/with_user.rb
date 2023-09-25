RSpec.shared_context 'with user' do
  let(:user) { create(:user, :registered) }

  before do
    visit '/users/sign-in'
    fill_in 'Email address', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Sign in'
  end
end
