require 'rails_helper'

RSpec.describe Training::QuestionResponse do
  let(:user) { create :user }
  let(:question) { Training::Question.find_by(module_id: 'child-development-and-the-eyfs', slug: '1-1-1-1b').first }
  let(:question_response) { Training::QuestionResponse.new(user: user, question: question) }

  context 'user answers for the first time' do
    xspecify { expect(question_response).to be_unanswered }
  end

  context 'user has previously answered' do
    xspecify { expect(question_response).to_not be_unanswered }
  end
end