require 'rails_helper'

RSpec.describe Data::UserModuleOrder do
  let(:headers) do
    [
      'Following Linear Sequence',
      'Not Following Linear Sequence',
    ]
  end

  let(:rows) do
    [
      {
        linear_activity: 0,
        non_linear_activity: 0,
      },
    ]
  end

  # TODO: module_start events

  before do
    create :user, :registered, module_time_to_completion: { alpha: 1, bravo: 1, charlie: 0 }
    create :user, :registered, module_time_to_completion: { alpha: 2, bravo: 3, charlie: 1 }
    create :user, :registered, module_time_to_completion: { alpha: 2, bravo: 0, charlie: 1 }
    create :user, :registered, module_time_to_completion: { alpha: 2, charlie: 1, bravo: 3 }
  end

  it_behaves_like 'a data export model'
end
