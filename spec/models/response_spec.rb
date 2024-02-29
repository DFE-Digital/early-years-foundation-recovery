require 'rails_helper'

RSpec.describe Response, type: :model do
  subject(:response) { user.response_for(question) }

  before do
    skip unless Rails.application.migrated_answers?
    response.update!(answers: [1], correct: true)
  end

  let(:user) { create :user }

  let(:headers) do
    %w[
      id
      user_id
      training_module
      question_name
      answers
      correct
      created_at
      updated_at
      question_type
      assessment_id
      text_input
    ]
  end

  let(:rows) do
    [response]
  end

  let(:question) do
    Training::Module.by_name('alpha').page_by_name('1-1-4-1')
  end

  it_behaves_like 'a data export model'
end
