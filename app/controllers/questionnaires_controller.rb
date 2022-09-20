class QuestionnairesController < ApplicationController
  before_action :authenticate_registered_user!, :module_item
  before_action :track_events, only: :show

  def show
    questionnaire_taker.prepare
  end

  def update
    # TODO: why?
    # questionnaire_taker.archive

    immediate_feedback if questionnaire.formative?
    marked_assessment if questionnaire.summative?
    next_question if questionnaire.confidence?
  end

protected

  def module_item
    @module_item ||= ModuleItem.find_by(training_module: module_params['training_module_id'], name: module_params['id'])
  end

  def questionnaire
    @questionnaire ||= Questionnaire.find_by!(name: module_params[:id], training_module: module_params[:training_module_id])
  end

  def questionnaire_taker
    @questionnaire_taker ||= QuestionnaireTaker.new(user: current_user, questionnaire: questionnaire)
  end

  def next_item_path(item)
    if item.next_item
      training_module_content_page_path(item.training_module, item.next_item)
    else
      course_overview_path
    end
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

  def immediate_feedback
    if unanswered?
      flash[:error] = 'Please select an answer'
    else
      populate_and_persist
      track_questionnaire_answer
    end

    render :show, status: :unprocessable_entity
  end

  def next_question
    if unanswered?
      flash[:error] = 'Please select an answer'
      render :show, status: :unprocessable_entity
    else
      populate_and_persist
      track_questionnaire_answer

      redirect_to next_item_path(questionnaire.module_item)
    end
  end

  def marked_assessment
    if unanswered?
      flash[:error] = 'Please select an answer'
      render :show, status: :unprocessable_entity
    else
      populate_and_persist
      track_questionnaire_answer

      mod = questionnaire.module_item.parent

      if questionnaire.last_assessment?
        helpers.assessment_progress(mod).save!
        redirect_to training_module_assessment_result_path(mod, mod.assessment_results_page)
      else
        redirect_to next_item_path(questionnaire.module_item)
      end
    end
  end

  def track_questionnaire_answer
    key = questionnaire.questions.keys.first

    track('questionnaire_answer',
          type: questionnaire.assessments_type,
          success: questionnaire.result_for(key),
          answer: questionnaire.answer_for(key))
  end

private

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
end
