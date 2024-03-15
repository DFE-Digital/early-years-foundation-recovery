require 'rails_helper'

RSpec.describe DataAnalysis::FeedbackForms do
  let(:headers) do
    [
      'Module',
      'Total Responses',
      'Signed in Users',
      'Guest Users',
    ]
  end

  let(:rows) do
    [
      {
        mod: 'alpha',
        total: 2,
        signed_in: 2,
        guest: 0,
      },
      {
        mod: 'bravo',
        total: 0,
        signed_in: 0,
        guest: 0,
      },
      {
        mod: 'charlie',
        total: 0,
        signed_in: 0,
        guest: 0,
      },
      {
        mod: 'delta',
        total: 0,
        signed_in: 0,
        guest: 0,
      },
      {
        mod: 'site wide',
        total: 2,
        signed_in: 1,
        guest: 1,
      },
    ]
  end

  let(:user) { create(:user, :registered) }

  before do
    create :event, :feedback_complete, user_id: user.id, properties: { 'training_module_id' => 'alpha' }
    create :event, :feedback_complete, user_id: user.id, properties: { 'training_module_id' => 'alpha' }
    create :event, :feedback_complete, user_id: user.id, properties: { 'controller' => 'feedback' }
    create :event, :feedback_complete, user_id: nil, properties: { 'controller' => 'feedback' }
  end

  it_behaves_like 'a data export model'
end
