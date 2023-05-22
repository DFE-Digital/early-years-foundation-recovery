require 'rails_helper'

RSpec.describe Data::LocalAuthorityUser do
  let(:user) do
    create(:user, :registered, local_authority: 'LA1', created_at: Time.zone.now)
  end

  let(:user_2) do
    create(:user, :registered, local_authority: 'LA1', created_at: Time.zone.now)
  end

  let(:pre_public_beta) do
    create(:user, :registered, local_authority: 'LA3', created_at: Time.zone.local(2023, 2, 9, 14, 0, 0))
  end

  describe '.to_csv' do
    context 'when no users exist' do
      it 'creates csv data with columns but no rows' do
        expect(described_class.to_csv).to eq("Local Authority,Users\n")
      end
    end

    context 'when users has been created before public beta launch' do
      it 'creates csv data and ignores users created before that date' do
        expect(pre_public_beta.created_at).to eq(Time.zone.local(2023, 2, 9, 14, 0, 0))
        expect(described_class.to_csv).to eq("Local Authority,Users\n")
      end
    end

    context 'when user has been created after public beta launch' do
      it 'creates csv data and includes the users in the total for that local authority' do
        expect(user.local_authority).to eq('LA1')
        expect(described_class.to_csv).to eq("Local Authority,Users\nLA1,1\n")
      end
    end

    context 'when multiple users have the same local authority' do
      it 'creates csv data and includes the users in the total for that local authority' do
        expect(user.local_authority).to eq('LA1')
        expect(user_2.local_authority).to eq('LA1')
        expect(described_class.to_csv).to eq("Local Authority,Users\nLA1,2\n")
      end
    end
  end
end
