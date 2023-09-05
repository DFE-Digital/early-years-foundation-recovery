require 'rails_helper'

RSpec.describe CompleteRegistrationMailJob do
  let(:template) { :complete_registration }

  let(:included) do
    create_list :user, 3, confirmed_at: 4.weeks.ago
  end

  let(:excluded) do
    [
      create(:user, :registered, confirmed_at: 4.weeks.ago),
      create(:user, confirmed_at: 2.months.ago),
    ]
  end

  # 1 user receives the :complete_registration email template
  it_behaves_like 'an email prompt'
end
