require 'rails_helper'

RSpec.describe PopulateLastLoggedInAtJob do
  context 'when users have no last_logged_in_at' do
    let(:user_1) { create(:user, :registered) }
    let(:user_2) { create(:user, :registered) }
    let(:user_3) { create(:user, :registered) }
    let!(:visit_1) { create(:visit, visitor_token: '123', user_id: user_1.id, started_at: 1.day.ago) }
    let!(:visit_2) { create(:visit, visitor_token: '234', user_id: user_2.id, started_at: 2.days.ago) }

    before do
      create(:visit, visitor_token: '123', user_id: user_1.id, started_at: 3.days.ago)
      create(:visit, visitor_token: '123', user_id: user_1.id, started_at: 2.days.ago)
      described_class.run
    end

    it 'updates last_logged_in_at with the last visit date' do
      expect(user_1.reload.last_logged_in_at).to eq(visit_1.started_at)
      expect(user_2.reload.last_logged_in_at).to eq(visit_2.started_at)
      expect(user_3.reload.last_logged_in_at).to eq(nil)
    end
  end
end
