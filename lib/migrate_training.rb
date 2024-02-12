# Pre:
#   UserAnswer is assigned UserAssessment upon answering the last question meaning:
#   - foreign keys may be missing and not every UserAnswer has a UserAssessment
#
# Post:
#   Assessment is created with the first Response meaning:
#   - every Assessment has a minimum of 1 Response
#   - every Assessmment has a maximum of 10 Responses
#
#
class MigrateTraining


  def call
    ActiveRecord::Base.transaction do
      truncate!

      # Consider redacted users

      UserAnswer.all.order(:created_at).find_each do |user_answer|

        # association present
        if user_answer.user_assessment_id.present?

          # or ActiveRecord::RecordNotFound ?
          user_assessment = UserAssessment.find(user_answer.user_assessment_id)
          assessment = Assessment.find_or_create_by **assessment_params(user_assessment)

        # association missing
        else

          inflight_params = {
            user_id: user_answer.user_id,
            training_module: user_answer.module,
            started_at: user_answer.created_at,
          }

          assessment = Assessment.find_or_create_by **inflight_params
        end

        Response.create! **response_params(user_answer), assessment_id: assessment.id
      end
    end
  end

  private

  # @return [?]
  def truncate!
    puts 'Truncate responses'
    ActiveRecord::Base.connection.execute('TRUNCATE responses RESTART IDENTITY CASCADE')

    puts 'Truncate assessments'
    ActiveRecord::Base.connection.execute('TRUNCATE assessments RESTART IDENTITY CASCADE')
  end

  # @param user_answer [UserAssessment]
  # @return [Hash<Symbol=>Mixed>]
  def assessment_params(user_assessment)
    {
      id: user_assessment.id,                                                          # int primary key
      user_id: user_assessment.user_id,                                                # int foreign key
      training_module: user_assessment.module,                                         # string foreign key
      score: user_assessment.score,                                                    # float
      passed: user_assessment.status.eql?('passed'),                                   # bool
      started_at: user_assessment.user_answers.order(:created_at).first.created_at,    # datetime
      completed_at: user_assessment.created_at,                                        # datetime
    }
  end

  # @param user_answer [UserAnswer]
  # @return [Hash<Symbol=>Mixed>]
  def response_params(user_answer)
    {
      id: user_answer.id,                               # int primary key
      user_id: user_answer.user_id,                     # int foreign key
      assessment_id: user_answer.user_assessment_id,    # int foreign key
      training_module: user_answer.module,              # string foreign key
      question_name: user_answer.name,                  # string foreign key
      question_type: user_answer.assessments_type,      # string
      answers: user_answer.answer,                      # array
      correct: user_answer.correct,                     # bool
      created_at: user_answer.created_at,               # datetime
      updated_at: user_answer.updated_at,               # datetime
    }
  end

end
