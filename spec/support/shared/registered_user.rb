RSpec.shared_context 'with registered user' do
  let(:user) { create(:user, :registered) }

  before do
    visit '/users/sign_in'
    fill_in 'Email address', with: user.email
    fill_in 'Password', with: 'StrongPassword123'
    click_button 'Sign in'
  end
end
