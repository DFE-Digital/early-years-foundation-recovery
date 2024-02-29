# BEFORE
#
#   UserAnswer is assigned UserAssessment upon answering the last question meaning:
#     - foreign keys may be missing and not every UserAnswer has a UserAssessment
#
# AFTER
#
#   Assessment is created with the first Response meaning:
#     - every Assessment has a minimum of 1 Response
#     - every Assessment has a maximum score of 100%
#
#
class MigrateTraining
  class Error < StandardError
  end

  extend Dry::Initializer

  # @return [Boolean]
  option :truncate, Types::Bool, default: proc { false }, reader: :private
  # @return [Boolean]
  option :simulate, Types::Bool, default: proc { false }, reader: :private
  # @return [Boolean]
  option :verbose, Types::Bool, default: proc { true }, reader: :private
  # @return [Integer, nil]
  option :resume, Types::Integer, optional: true, reader: :private

  # @return [nil]
  def call
    ActiveRecord::Base.transaction do
      log "Migration started: #{Time.zone.now}"
      truncate! if truncate
      migrate!
      log "Migration finished: #{Time.zone.now}"
      raise Error if simulate
    end
  end

private

  # @return [PG::Result]
  def truncate!
    log 'Truncate responses and assessments'
    ActiveRecord::Base.connection.execute 'TRUNCATE responses, assessments RESTART IDENTITY'
  end

  # @return [nil]
  def migrate!
    UserAnswer.find_in_batches(start: resume, batch_size: 100) do |group|
      group.each do |user_answer|
        if valid?(user_answer)
          response = process_user_answer(user_answer)
          log response.attributes.to_json, alert: false
        else
          log "User: #{user_answer.user_id} UserAnswer: #{user_answer.id}"
        end
      end

      # GC.start
    end
  end

  # @param user_answer [UserAnswer]
  # @return [Boolean]
  def valid?(user_answer)
    if user_answer.name.blank? ||
        user_answer.module.blank? ||
        user_answer.assessments_type.blank? ||
        user_answer.question.nil? ||
        !user_answer.question.respond_to?(:question_type)
      false
    else
      true
    end
  end

  # @param user_answer [UserAnswer]
  # @return [Response]
  def process_user_answer(user_answer)
    assessment = process_user_assessment(user_answer)
    params = response_params(user_answer)

    Response.create(**params, assessment_id: assessment&.id)
  end

  # @param user_answer [UserAnswer]
  # @return [Assessment, nil]
  def process_user_assessment(user_answer)
    return unless user_answer.question.summative_question?

    if user_answer.user_assessment_id.nil?
      assessment =
        Assessment
          .create_with(started_at: user_answer.created_at)
          .find_or_create_by(user_id: user_answer.user_id, training_module: user_answer.module)
    else
      user_assessment = UserAssessment.find(user_answer.user_assessment_id)
      params = assessment_params(user_assessment)
      assessment = Assessment.find_or_create_by(params)

      if assessment.score.nil?
        if user_assessment.score.to_i > 100
          assessment.update(score: 100)
        else
          assessment.update(score: user_assessment.score)
        end
      end
    end

    assessment
  end

  # @param user_assessment [UserAssessment]
  # @return [Hash<Symbol=>Mixed>]
  def assessment_params(user_assessment)
    {
      id: user_assessment.id,                                                          # int primary key
      user_id: user_assessment.user_id,                                                # int foreign key
      training_module: user_assessment.module,                                         # string foreign key
      passed: user_assessment.status.eql?('passed'),                                   # bool
      started_at: user_assessment.user_answers.order(:created_at).first.created_at,    # datetime
      completed_at: user_assessment.created_at,                                        # datetime
    }
  end

  # @param user_answer [UserAnswer]
  # @return [Hash<Symbol=>Mixed>]
  def response_params(user_answer)
    {
      id: user_answer.id,                                   # int db primary key
      user_id: user_answer.user_id,                         # int db foreign key
      assessment_id: user_answer.user_assessment_id,        # int db foreign key
      training_module: user_answer.module,                  # string cms key
      question_name: user_answer.name,                      # string cms key
      question_type: user_answer.question.question_type,    # string cms filter
      answers: user_answer.answer,                          # array
      correct: user_answer.correct,                         # bool
      created_at: user_answer.created_at,                   # datetime
      updated_at: user_answer.updated_at,                   # datetime
    }
  end

  # @param message [String]
  # @param alert [Boolean] Send to Sentry
  # @return [String, nil]
  def log(message, alert: true)
    if Rails.env.production?
      Rails.logger.info(message)

      if alert
        alert_message = "#{self.class.name}: #{ENV['ENVIRONMENT']} - #{message}"
        Sentry.capture_message(alert_message, level: :info)
      end
    elsif verbose
      puts message
    end
  end
end
