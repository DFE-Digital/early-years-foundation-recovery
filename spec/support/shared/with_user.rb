RSpec.shared_context 'with user' do
  let(:user) { create(:gov_one_user) }

  before do
    sign_in user
    visit '/users/sign-in'
  end
end
