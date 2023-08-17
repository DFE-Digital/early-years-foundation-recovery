require 'rails_helper'

RSpec.describe Data::UserModuleCompletionCount do
  let(:headers) do
    [
      '1 Completed',
      '2 Completed',
      '3 Completed',
    ]
  end

  let(:rows) do
    [
      {
        '1': 1,
        '2': 2,
        '3': 1,
      },
    ]
  end

  before do
    create :user, :confirmed
    create :user, :registered, module_time_to_completion: { alpha: 1 }
    create :user, :registered, module_time_to_completion: { alpha: 1, charlie: 1 }
    create :user, :registered, module_time_to_completion: { alpha: 0 }
    create :user, :registered, module_time_to_completion: { bravo: 1, alpha: 1 }
    create :user, :registered, module_time_to_completion: { alpha: 1, bravo: 1, charlie: 1 }
  end

  it_behaves_like 'a data export model'
end
