require 'rails_helper'

RSpec.describe 'My modules', :vcr, type: :request do
  describe 'GET /my-modules' do
    before do
      sign_in create(:user, :registered)
    end

    specify { expect('/my-modules').to be_successful }

    it 'lists training modules' do
      get my_modules_path
      expect(response.body).to include('My modules')
    end
  end
end
