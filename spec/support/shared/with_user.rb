RSpec.shared_context 'with user' do
  let(:user) { create(:user, :registered) }

  before do
    sign_in user
    visit '/users/sign-in'
  end
end
