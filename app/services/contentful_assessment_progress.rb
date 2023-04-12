# Summative assessment evaluation
#
class ContentfulAssessmentProgress
  extend Dry::Initializer

  # @!attribute [r] user
  #   @return [User]
  option :user, Types.Instance(User), required: true
  # @!attribute [r] mod
  #   @return [Training::Module]
  option :mod, Types.Instance(Training::Module), required: true

  def save!
    assess = UserAssessment.create!(
      user_id: user.id,
      score: score.to_i,
      status: status,
      module: mod.name,
      assessments_type: 'summative_assessment',
    )

    if summative_responses.all?(&:persisted?) && assess.persisted?
      summative_responses.each do |response|
        response.update(user_assessment_id: assess.id)
      end
    end
  end

  # @see ContentHelper#results_banner
  #
  # @return [Hash]
  def result
    { success: passed?, score: score.to_i }
  end

  # @return [Symbol]
  def status
    passed? ? :passed : :failed
  end

  # @return [Boolean]
  def passed?
    score >= mod.summative_threshold
  end

  # @return [Boolean]
  def failed?
    !passed?
  end

  # @return [Boolean] CTA failed_attempt state
  def attempted?
    user.user_assessments.where(assessments_type: 'summative_assessment', module: mod.name).any?
  end

  # @return [Float] percentage of correct responses
  def score
    (correct_responses.count.to_f / mod.summative_questions.count) * 100
  rescue ZeroDivisionError
    0.0
  end

  # @return [?]
  def archive
    summative_responses.each do |response|
      response.update!(archive: true)
    end
  end

  # @return [Array<Response>]
  def incorrect_responses
    summative_responses.reject(&:correct?)
  end

private

  # @return [Array<Response>]
  def summative_responses
    user.responses.unarchived.where(training_module: mod.name).select(&:summative?)
  end

  # @return [Array<Response>]
  def correct_responses
    summative_responses.select(&:correct?)
  end
end
