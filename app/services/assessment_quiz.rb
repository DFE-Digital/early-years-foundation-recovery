class AssessmentQuiz
  def initialize(user:, type:, training_module_id:, name:)
    @user = user
    @type = type
    @training_module_id = training_module_id
    @name = name
    @type_assesment_result = 'assessments_results'
    module_item
    training_module
  end

  def questions_list
    @questions_list ||= SummativeQuestionnaire.where(training_module: @training_module_id)
  end

  def user_saved_answers
    @user.user_answers.not_archived.where(assessments_type: @type, module: @training_module_id, correct: true)
  end

  def correct_answer?
    @user.user_answers.not_archived.where(assessments_type: @type, module: @training_module_id, correct: true, name: @name).exists?
  end

  def user_saved_incorrect_answers
    @user.user_answers.not_archived.where(assessments_type: @type, module: @training_module_id, correct: false)
  end

  def calculate_status
    percentage_of_assessment_answers_correct >= @training_module.summative_threshold ? 'passed' : 'failed'
  rescue StandardError
    'not started'
  end

  def check_if_saved_result
    answer_user = existing_user_assessment_answers.first
    true if defined?(answer_user.user_assessment_id) && answer_user.user_assessment_id.present?
  rescue StandardError
    false
  end

  def save_user_assessment
    user_assessment = UserAssessment.create!(
      user_id: @user.id,
      score: percentage_of_assessment_answers_correct,
      status: calculate_status,
      module: @training_module_id,
      assessments_type: @type,
    )

    if user_assessment.id.present?
      existing_user_assessment_answers.update_all(user_assessment_id: user_assessment.id)
    end
  rescue StandardError
    []
  end

  def percentage_of_assessment_answers_correct
    (user_saved_answers.length / questions_list.length.to_f * 100).round(0)
  end

  def questionnaire(name:, training_module:)
    Questionnaire.find_by!(name: name, training_module: training_module)
  end

  def archive_previous_user_assessment_answers
    existing_user_assessment_answers.update_all(archived: true)
  end

  def existing_user_assessment_answers
    @user.user_answers.not_archived.where(assessments_type: @type, module: @training_module_id)
  end

  def get_answers
    @user.user_answers.not_archived.where(assessments_type: @type, module: @training_module_id, name: @name)
  end

  def module_item
    @module_item ||= ModuleItem.where(training_module: @training_module_id)
  end

  def get_all_type_pages
    @module_item.group_by(&:type)
  end

  # This assumes page before the first assessment page will be the intro page
  def assessment_intro_page
    module_item_page = ModuleItem.find_by(training_module: @training_module_id, name: assessment_first_page.name)
    module_item_page.previous_item
  end

  def training_module
    @training_module ||= TrainingModule.find_by(name: @training_module_id)
  end

  def assessment_first_page
    get_all_type_pages[@type].first
  end

  def assessment_last_page
    get_all_type_pages[@type].last
  end

  def assessment_results_page
    get_all_type_pages[@type_assesment_result]
  end

  def last_page_visited
    results = @user.user_answers.not_archived.where(assessments_type: @type, module: @training_module_id).sort_by(&:created_at)
    if results.blank?
      false
    else
      results.last
    end
  end

  def check_if_assessment_taken
    results = @user.user_assessments.where(assessments_type: @type, module: @training_module_id).sort_by(&:created_at)
    Rails.logger.debug results.inspect
    results.blank? ? false : true
  end
end
