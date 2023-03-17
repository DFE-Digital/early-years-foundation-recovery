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
    UserAssessment.create!(
      user_id: user.id,
      score: score.to_i,
      status: status,
      module: mod.name,
      assessments_type: 'summative_assessment',
    )
  end

  # @see ContentHelper#results_banner
  #
  # @return [Hash]
  def result
    { success: passed?, score: score.to_i }
  end

  # @see #passed?
  #
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

  # @return [Float] percentage of correct responses
  def score
    (correct_responses.count.to_f / questions.count) * 100
  rescue ZeroDivisionError
    0.0
  end

private

  # @return
  def correct_responses
    user.responses.select{|response| response.assessments_type.eql?('summative_assessment') && response.correct?}
  end

  # @return
  def responses
    user.responses.summative_for(mod)
  end

  # @return
  def questions
    @questions ||= mod.summative_questions
  end
end
