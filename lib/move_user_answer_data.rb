class MoveUserAnswerData
  def call
    user_answers.find_each(batch_size: 1000) do |user_answer|
      Response.create(
        user_id: user_answer.user_id,
        training_module: user_answer.module,
        question_name: user_answer.name,
        answer: user_answer.answer,
        archive: user_answer.archived,
        user_assessment_id: user_answer.user_assessment_id,
      )
    end
  end

  def user_answers
    User::Answer.order(:id).all
  end
end