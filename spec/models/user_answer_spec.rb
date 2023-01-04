require 'rails_helper'

RSpec.describe UserAnswer, type: :model do
  subject(:user_answer) do
    create(:user_answer,
           name: questionnaire.name,
           module: questionnaire.training_module,
           questionnaire_id: questionnaire.id)
  end

  context 'CMS Content' do
    before do
      ENV['CONTENTFUL_MODULES'] = 'alpha'
    end

    let(:questionnaire) do
      Questionnaire.find_by!(name: '1-1-4', training_module: 'alpha') # original YAML sourced questionnaire
    end

    it 'is associated with a questionnaire' do
      expect(user_answer.questionnaire).to be_a(Training::Question)
      expect(user_answer.questionnaire.questions.slug).to eql '1-1-4'
    end
  end

  context 'Original YAML Content' do
    let(:questionnaire) do
      Questionnaire.find_by!(name: '1-2-2-2', training_module: 'bravo') # original YAML sourced questionnaire
    end

    it 'is associated with a questionnaire' do
      expect(user_answer.questionnaire).to be_a(Questionnaire) # Still YAML!
      expect(user_answer.questionnaire.questions.keys).to eql [:bravo_summative_question_one]
    end
  end
end
