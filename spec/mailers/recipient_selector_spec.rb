require 'rails_helper'

RSpec.describe RecipientSelector do
  subject(:recipient_selector) { Class.new { extend RecipientSelector } }

  describe '.complete_registration_recipients' do
    let!(:user_1) { create(:user, confirmed_at: 4.weeks.ago) }
    let!(:user_2) { create(:user, confirmed_at: 4.weeks.ago) }
    let!(:user_3) { create(:user, confirmed_at: 4.weeks.ago) }

    before do
      create(:user, :registered, confirmed_at: 1.month.ago)
      create(:user, confirmed_at: 2.months.ago)
    end

    context 'when users are a month old but have not completed registration' do
      it 'returns the users but no others' do
        expect(recipient_selector.complete_registration_recipients).to contain_exactly(user_1, user_2, user_3)
      end
    end
  end

  describe '.start_training_recipients' do
    let!(:user_1) { create(:user, :registered, confirmed_at: 4.weeks.ago) }
    let!(:user_2) { create(:user, :registered, confirmed_at: 4.weeks.ago) }
    let!(:user_3) { create(:user, :registered, confirmed_at: 4.weeks.ago) }

    before do
      create(:user, :registered, confirmed_at: 2.months.ago)
      create(:user, :registered, confirmed_at: 4.weeks.ago, module_time_to_completion: { "alpha": 0 })
    end

    context 'when users are a month old and have completed registration but not started training' do
      it 'returns the users but no others' do
        expect(recipient_selector.start_training_recipients).to contain_exactly(user_1, user_2, user_3)
      end
    end
  end
end
