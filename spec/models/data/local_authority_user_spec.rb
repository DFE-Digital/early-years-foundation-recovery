require 'rails_helper'

RSpec.describe Data::LocalAuthorityUser do
  let(:registered) do
    create(:user, :registered, local_authority: 'LA1', created_at: Time.zone.now)
  end

  let(:registered2) do
    create(:user, :registered, local_authority: 'LA1', created_at: Time.zone.now)
  end

  let(:unregistered) do
    create(:user, registration_complete: false, local_authority: 'LA2', created_at: Time.zone.now)
  end

  let(:pre_public_beta) do
    create(:user, :registered, local_authority: 'LA3', created_at: Time.zone.local(2023, 2, 9, 14, 0, 0))
  end

  describe '.to_csv' do
    context 'when no users exist' do
      it 'creates csv data with columns but no rows' do
        expect(described_class.to_csv).to eq("Local Authority,Total Users,Registration Completed\n")
      end
    end

    context 'when users created before 09/02/23 exist' do
      it 'creates csv data and ignores users created before that date' do
        expect(pre_public_beta.created_at).to eq(Time.zone.local(2023, 2, 9, 14, 0, 0))
        expect(described_class.to_csv).to eq("Local Authority,Total Users,Registration Completed\n")
      end
    end

    context 'when users have not completed registration' do
      it 'creates csv data and includes users in the total but not registration completed' do
        expect(unregistered.local_authority).to eq('LA2')
        expect(unregistered.registration_complete).to eq(false)
        expect(described_class.to_csv).to eq("Local Authority,Total Users,Registration Completed\nLA2,1,0\n")
      end
    end

    context 'when a user has completed registration' do
      it 'creates csv data and includes the user in the total and registration completed' do
        expect(registered.local_authority).to eq('LA1')
        expect(registered.registration_complete).to eq(true)
        expect(described_class.to_csv).to eq("Local Authority,Total Users,Registration Completed\nLA1,1,1\n")
      end
    end

    context 'when multiple users have the same local authority' do
      it 'creates csv data and includes the users in the total and registration_completed for that local authority' do
        expect(registered.local_authority).to eq('LA1')
        expect(registered2.local_authority).to eq('LA1')
        expect(registered.registration_complete).to eq(true)
        expect(registered2.registration_complete).to eq(true)
        expect(described_class.to_csv).to eq("Local Authority,Total Users,Registration Completed\nLA1,2,2\n")
      end
    end
  end
end
