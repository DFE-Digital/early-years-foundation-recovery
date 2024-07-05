require 'rails_helper'

RSpec.describe Response, '#feedback', type: :model do
  let(:user) { create :user }
  let(:params) do
    {
      training_module: 'alpha',
      correct: true,
      user: user,
      question_type: 'feedback',
    }
  end

  before do
    skip unless Rails.application.migrated_answers?
  end

  # validate answers array
  describe '#answers' do
    subject(:response) do
      build :response,
            **params,
            question_name: 'feedback-skippable',
            answers: [1]
    end

    specify { expect(response).to be_valid }
  end
end
