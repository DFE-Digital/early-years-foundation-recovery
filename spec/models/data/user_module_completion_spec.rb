require 'rails_helper'

RSpec.describe Data::UserModuleCompletion do
  include_context 'with progress'
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
        completed_percentage: 0.5,
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
    create :user, :registered
    complete_module(Training::Module.by_name('alpha'))
    start_module(Training::Module.by_name('bravo'))
  end

  it_behaves_like 'a data export model'
end
