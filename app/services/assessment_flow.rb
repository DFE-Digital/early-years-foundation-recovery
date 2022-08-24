class AssessmentFlow
  include Rails.application.routes.url_helpers
  def initialize(user:, type:, mod:, request:)
      @type = type
      @mod = mod
      @user = user
      @request = request
      assessment_progress
      questions
  end

  def authenticate_flow
    puts 'referrer'
    puts attempted
    puts 'referrer'
    retake_quiz if !module_question_paths.include? referrer
  end

  def attempted
    return if !module_question_paths.include? referrer
  end

  def referrer
    URI(@request.referrer).path if @request.referrer.present?
  end

  def current_url
    URI(@request.original_url).path if @request.original_url.present?
  end

  def page_refreshed
    
  end

  def module_question_paths
    module_urls = []
    
    module_urls.push(intro_page)
    module_urls.push(results_page)

    questions.each do |question| 
      module_urls.push(training_module_questionnaire_path(question.training_module, question)) 
    end

    module_urls
  end
  
  def assessment_progress
    @assessment_progress ||= SummativeAssessmentProgress.new(user: @user, mod: @mod)
  end

  def questions
    @questions ||= SummativeQuestionnaire.where(training_module: @mod.name)
  end

  def intro_page
    training_module_content_page_path(training_module.assessment_results_page.training_module, training_module.assessment_intro_page)
  end

  def training_module
    @training_module ||= TrainingModule.find_by(name: @mod.name) 
  end

  def results_page
    training_module_assessment_result_path(training_module.assessment_results_page.training_module, training_module.assessment_results_page)
  end

  def retake_quiz
    @assessment_progress.save!
    @assessment_progress.archive_attempt
  end
end
