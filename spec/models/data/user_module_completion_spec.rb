require 'rails_helper'

RSpec.describe Data::UserModuleCompletion do
  let(:headers) do
    [
      'Module Name',
      'Completed Count',
      'Completed Percentage',
    ]
  end

  let(:rows) do
    [
      {
        module_name: 'alpha',
        completed_count: 1,
        completed_percentage: 0.3333333333333333,
      },
      {
        module_name: 'bravo',
        completed_count: 0,
        completed_percentage: 0.0,
      },
      {
        module_name: 'charlie',
        completed_count: 0,
        completed_percentage: 0.0,
      },
    ]
  end

  before do
    create :user, :confirmed
    create :user, :registered
    create :user, :registered, module_time_to_completion: { alpha: 0 }
    create :user, :registered, module_time_to_completion: { alpha: 1 }
  end

  it_behaves_like 'a data export model'
end
