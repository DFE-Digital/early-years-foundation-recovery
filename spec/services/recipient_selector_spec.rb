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

  describe '.continue_training_recipients' do
    let!(:user_1) { create(:user, :registered, confirmed_at: 4.weeks.ago, module_time_to_completion: { "alpha": 0 }) }
    let!(:user_2) { create(:user, :registered, confirmed_at: 4.weeks.ago, module_time_to_completion: { "alpha": 0 }) }
    let!(:user_3) { create(:user, :registered, confirmed_at: 4.weeks.ago, module_time_to_completion: { "alpha": 0 }) }

    before do
      create(:user, :registered, confirmed_at: 4.weeks.ago, module_time_to_completion: { "alpha": 1 })
      create(:user, :registered, confirmed_at: 8.weeks.ago, module_time_to_completion: { "alpha": 2 })

      Ahoy::Visit.new(
        id: 1,
        visitor_token: '123',
        user_id: user_1.id,
        started_at: 4.weeks.ago,
      ).save!

      Ahoy::Visit.new(
        id: 2,
        visitor_token: '234',
        user_id: user_1.id,
        started_at: 2.weeks.ago,
      ).save!

      Ahoy::Visit.new(
        id: 3,
        visitor_token: '345',
        user_id: user_2.id,
        started_at: 4.weeks.ago,
      ).save!

      Ahoy::Visit.new(
        id: 4,
        visitor_token: '456',
        user_id: user_3.id,
        started_at: 4.weeks.ago,
      ).save!
    end

    context 'when users are a month old and have completed registration and started training but not completed training' do
      it 'returns the users but no others' do
        expect(recipient_selector.continue_training_recipients).to contain_exactly(user_2, user_3)
      end
    end
  end
end
