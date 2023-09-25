# :nocov:
#
# Seed user training module state
#
class ContentSeed
  extend Dry::Initializer

  # @!attribute [r] user
  #   @return [User]
  option :user, Types.Instance(User), required: true
  # @!attribute [r] mod
  #   @return [Training::Module]
  option :mod, Types.Instance(Training::Module), required: true

  # @return [Array<Array>]
  def call
    mod.content.each do |content|
      create_event(slug: content.name)
      create_event(slug: content.name, name: 'module_start') if content.submodule_intro? && !started?
      create_event(slug: content.name, name: 'module_complete') if content.certificate?
      create_answer(content) if content.is_question?
    end
  end

private

  # @return [Boolean]
  def started?
    user.events.find_by(name: 'module_start').present?
  end

  # @return [UserAssessment]
  def assessment
    @assessment ||= UserAssessment.create(
      user_id: user.id,
      module: mod.name,
      score: 100,
    )
  end

  # @param question [Training::Question]
  # @return [UserAnswer]
  def create_answer(question)
    UserAnswer.create(
      user_id: user.id,
      questionnaire_id: 0,
      question: question.body,
      answer: question.answer.correct_answers,
      correct: true,
      archived: true,
      module: mod.name,
      name: question.name,
      assessments_type: question.assessments_type,
      user_assessment_id: (assessment.id if question.summative_question?),
    )
  end

  # @return [Ahoy::Event]
  def create_event(slug:, name: 'module_content_page')
    user.events.create!(
      visit_id: visit.id,
      user_id: user.id,
      name: name,
      time: time,
      properties: {
        id: slug,
        training_module_id: mod.name,
      },
    )
  end

  # @return [Ahoy::Visit]
  def visit
    @visit ||= Ahoy::Visit.create(
      user_agent: 'ContentSeed',
      user_id: user.id,
      started_at: time,
    )
  end

  # @return [Time]
  def time
    @time ||= Time.zone.now
  end
end
# :nocov:
