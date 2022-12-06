RSpec.shared_context 'with user answer' do
  def create_user_answer(user, questionnaire_id, question, answer, correct, module_name, name, assessments_type, user_assessment_id)
    UserAnswer.new(user_id: user.id,
                   questionnaire_id: questionnaire_id,
                   question: question,
                   answer: answer,
                   correct: correct,
                   module: module_name,
                   name: name,
                   assessments_type: assessments_type,
                   user_assessment_id: user_assessment_id).save!
  end
end
