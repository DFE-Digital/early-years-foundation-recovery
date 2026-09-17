require 'rails_helper'

RSpec.describe DataAnalysis::ModuleFeedbackForms do
  let(:headers) do
    %w[
      Module
      Started
      Completed
    ]
  end

  let(:rows) do
    [
      {
        mod: 'First Training Module',
        started: 2,
        completed: 2,
      },
      {
        mod: 'Second Training Module',
        started: 1,
        completed: 1,
      },
      {
        mod: 'Third Training Module',
        started: 1,
        completed: 0,
      },
    ]
  end

  before do
    user_1 = create(:user)
    create :event, name: 'feedback_start', user: user_1, properties: { 'training_module_id' => 'alpha' }
    create :event, name: 'feedback_complete', user: user_1, properties: { 'training_module_id' => 'alpha' }
    create :event, name: 'feedback_start', user: user_1, properties: { 'training_module_id' => 'bravo' }
    create :event, name: 'feedback_complete', user: user_1, properties: { 'training_module_id' => 'bravo' }

    user_2 = create(:user)
    create :event, name: 'feedback_start', user: user_2, properties: { 'training_module_id' => 'alpha' }
    create :event, name: 'feedback_complete', user: user_2, properties: { 'training_module_id' => 'alpha' }

    user_3 = create(:user)
    create :event, name: 'feedback_start', user: user_3, properties: { 'training_module_id' => 'charlie' }
  end

  it_behaves_like 'a data export model'
end
