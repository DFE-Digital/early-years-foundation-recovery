require 'rails_helper'

RSpec.describe Ahoy::Visit, type: :model do
  subject(:visits) { described_class }

  describe '.dashboard' do
    before do
      create(:visit, started_at: Time.zone.now)
      create(:visit, started_at: 2.months.ago)
    end

    it 'includes current month only' do
      expect(visits.dashboard.count).to be 1
    end
  end
end
