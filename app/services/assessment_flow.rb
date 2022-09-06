class AssessmentFlow
  include Rails.application.routes.url_helpers
  # @param user [User]
  # @param type [String] :type of assessment
  # @param mod [TrainingModule]

  def initialize(user:, type:, mod:)
    @type = type
    @mod = mod
    @user = user
    assessment_type_progress
    questions
  end

  attr_reader :user, :mod, :type

  # @return [Boolean]
  def auth_summative_flow
    unless module_question_paths.include? referrer
      @assessment_type_progress.save!
      true
    end
  end

  # @return [Boolean]
  def auth_confidence_flow
    retake unless module_question_paths.include? referrer
  end

  def passed
    @assessment_type_progress.result_passed?
  end

  # @return [Boolean]
  def attempted
    return unless module_question_paths.include? referrer && assessment_type_progress.failed?
  end

  # @return [String]
  def referrer
    last_page_visited.properties['path']
  end

  # @return [Ahoy::Event::ActiveRecord_AssociationRelation]
  def training_module_events
    @user.events.order(time: :asc)
  end

  def last_page_visited
    training_module_events.last
  end

  # @return [Array]
  def module_question_paths
    module_urls = []

    module_urls.push(intro_page)
    module_urls.push(results_page)
    # module_urls.push(last_page)

    questions.each do |question|
      module_urls.push(training_module_questionnaire_path(question.training_module, question))
    end

    module_urls
  end

  # @return [ConfidenceCheckProgress::ActiveRecord || SummativeAssessmentProgress::ActiveRecord]
  def assessment_type_progress
    @assessment_type_progress = ConfidenceCheckProgress.new(user: @user, mod: @mod) if @type.to_s == CONFIDENCE
    @assessment_type_progress = SummativeAssessmentProgress.new(user: @user, mod: @mod) if @type.to_s == SUMMATIVE
  end

  # @return [SummativeQuestionnaire::ActiveRecord || ConfidenceQuestionnaire::ActiveRecord]
  def assessment_type
    if @type.to_s == SUMMATIVE
      SummativeQuestionnaire.where(training_module: @mod.name)
    end

    if @type.to_s == CONFIDENCE
      ConfidenceQuestionnaire.where(training_module: @mod.name)
    end
  end

  # @return [SummativeQuestionnaire::ActiveRecord || ConfidenceQuestionnaire::ActiveRecord]
  def questions
    @questions ||= assessment_type
  end

  # @return [String]
  def intro_page
    if @type.to_s == SUMMATIVE
      training_module_content_page_path(training_module.assessment_results_page.training_module, training_module.assessment_intro_page)
    end

    if @type.to_s == CONFIDENCE
      training_module_content_page_path(training_module.confidence_intro_page.training_module, training_module.confidence_intro_page)
    end
  end

  # @return [TrainingModule::ActiveRecord]
  def training_module
    @training_module ||= TrainingModule.find_by(name: @mod.name)
  end

  # @return [String]
  def results_page
    training_module_assessment_result_path(@training_module.assessment_results_page, @training_module.assessment_results_page)
  end

  # @return [String]
  def last_page
    training_module_content_page_path(training_module.confidence_thank_you_page.training_module, training_module.confidence_thank_you_page)
  end

  def retake
    @assessment_type_progress.save!
    @assessment_type_progress.archive_attempt
  end
end
