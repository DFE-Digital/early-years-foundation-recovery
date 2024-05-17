require 'rails_helper'

describe 'UserHelper', type: :helper do
  describe '#early_years_experience_patch' do
    subject(:experience) { helper.early_years_experience_patch }

    before do
      allow(helper).to receive(:current_user).and_return(user)
    end

    context 'with old data' do
      let(:user) do
        create(:user, :registered, early_years_experience: 'Old data')
      end

      it 'shows old data' do
        expect(experience).to eql 'Old data'
      end
    end

    context 'with new data id' do
      let(:user) do
        create(:user, :registered, early_years_experience: '2-5')
      end

      it 'shows the name' do
        expect(experience).to eql 'Between 2 and 5 years'
      end
    end
  end
end
