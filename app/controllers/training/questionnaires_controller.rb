class Training::QuestionnairesController < Training::BaseController
  before_action :authenticate_registered_user!, :module_item, :show_progress_bar
  before_action :track_events, only: :show
  helper_method :training_module
  
  def show
    questionnaire_taker.prepare
  end

  def update
    if unanswered?
      flash[:error] = 'Please select an answer'
      render :show, status: :unprocessable_entity
    else
      populate_and_persist
      track_questionnaire_answer
      redirect
    end
  end

protected

  def show_progress_bar
    @module_progress_bar = ModuleProgressBarDecorator.new(helpers.module_progress(training_module))
  end

  def module_item
    @module_item ||= questionnaire.module_item
  end

  def training_module
    module_item.parent
  end

  def questionnaire
    @questionnaire ||= Questionnaire.find_by!(name: module_params[:id], training_module: module_params[:training_module_id])
  end

  def questionnaire_taker
    @questionnaire_taker ||= QuestionnaireTaker.new(user: current_user, questionnaire: questionnaire)
  end

  def questionnaire_params
    params.require(:questionnaire).permit(questionnaire.permitted_methods)
  end

  def module_params
    params.permit(:training_module_id, :id)
  end

  def populate_and_persist
    questionnaire_taker.populate(questionnaire_params)
    questionnaire_taker.persist

    clear_flash
  end

  # return [Boolean]
  def unanswered?
    # radio_buttons
    return true unless params[:questionnaire]

    # check_boxes
    ((question_key, _data)) = questionnaire.questions.to_a
    check_boxes = params[:questionnaire][question_key]
    Array(check_boxes).compact_blank.empty?
  end

private

  def redirect
    if questionnaire.formative?
      redirect_to training_module_questionnaire_path(module_item.training_module, module_item)

    elsif questionnaire.summative?
      helpers.assessment_progress(module_item.parent).save! if questionnaire.last_assessment?

      redirect_to training_module_content_page_path(module_item.training_module, module_item.next_item)

    elsif questionnaire.confidence?
      redirect_to training_module_content_page_path(module_item.training_module, module_item.next_item)
    end
  end

  def track_events
    if questionnaire.first_confidence? && confidence_untracked?
      track('confidence_check_start')
    end

    if questionnaire.first_assessment? && summative_untracked?
      track('summative_assessment_start')
    end
  end

  def summative_untracked?
    untracked?('summative_assessment_start', training_module_id: params[:training_module_id])
  end

  def confidence_untracked?
    untracked?('confidence_check_start', training_module_id: params[:training_module_id])
  end

  def track_questionnaire_answer
    key = questionnaire.questions.keys.first

    track('questionnaire_answer',
          type: questionnaire.assessments_type,
          success: questionnaire.result_for(key),
          answer: questionnaire.answer_for(key))
  end
end
