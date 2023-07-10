require 'rails_helper'

RSpec.describe Data::LocalAuthorityUser do
  let(:headers) do
    ['Local Authority', 'Users']
  end

  let(:rows) do
    [
      {
        local_authority: 'LA1',
        users: 2,
      },
      {
        local_authority: 'LA3',
        users: 1,
      },
    ]
  end

  before do
    create(:user, :registered, local_authority: 'LA1', created_at: Time.zone.now)
    create(:user, :registered, local_authority: 'LA1', created_at: Time.zone.now)
    create(:user, :registered, local_authority: 'LA3', created_at: Time.zone.now)
  end

  context 'when there are rows and headers' do
    it 'returns the expected dashboard data' do
      expect(described_class.dashboard).to include(*rows)
    end

    it 'returns the expected column_names' do
      expect(described_class.column_names).to eq(headers)
    end
  end
end
