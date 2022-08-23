require 'rails_helper'

RSpec.describe Question, type: :model do
  describe '.find_by!' do
    subject(:question) do
      described_class.find_by!(
        training_module: :alpha,
        name: :'1-1-4',
        question: :alpha_question_one,
      )
    end

    specify { expect(question.name).to eq(:alpha_question_one) }
  end
end
