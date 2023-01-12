require 'rails_helper'

RSpec.describe UserAnswer, type: :model do
  subject(:user_answer) do
    create(:user_answer,
           name: questionnaire.name,
           module: questionnaire.training_module,
           questionnaire_id: questionnaire.id)
  end

  context 'with CMS Content' do
    before do
      allow(user_answer.questionnaire).to receive(:contentful?).and_return(true)
    end

    let(:questionnaire) do
      Questionnaire.find_by!(name: '1-1-4', training_module: 'alpha') # original YAML sourced questionnaire
    end

    it 'is associated with a questionnaire' do
      expect(user_answer.questionnaire).to be_a(Questionnaire) # Still YAML
      expect(user_answer.questionnaire.questions.keys).to eql [:alpha_question_one] # keys are the same (unused in Contentful)
      expect(user_answer.questionnaire.question_list.first.body).to match(/body in contentful/)
    end
  end

  context 'with Original YAML Content' do
    let(:questionnaire) do
      Questionnaire.find_by!(name: '1-2-2-2', training_module: 'bravo') # original YAML sourced questionnaire
    end

    it 'is associated with a questionnaire' do
      expect(user_answer.questionnaire).to be_a(Questionnaire) # Still YAML!
      expect(user_answer.questionnaire.questions.keys).to eql [:bravo_summative_question_one]
    end
  end
end
