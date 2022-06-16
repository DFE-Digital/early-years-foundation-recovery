require 'rails_helper'

RSpec.describe 'My learning', type: :request do
  describe 'GET /my-learning' do
    before do
      sign_in create(:user, :registered)
    end

    specify { expect('/my-learning').to be_successful }

    it 'lists training modules' do
      get my_learning_path
      expect(response.body).to include('My learning')
    end
  end
end
