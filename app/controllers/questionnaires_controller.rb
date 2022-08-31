class QuestionnairesController < ApplicationController
  before_action :authenticate_registered_user!
  before_action :track_events

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

  def track_summative_assessment_started?
    return false if questionnaire.module_item.parent.first_assessment_page.nil?

    questionnaire.module_item.parent.first_assessment_page.name == params[:id]
  end

  def summative_untracked?
    untracked?('summative_assessment_start', training_module_id: params[:training_module_id])
  end

  def track_confidence_check_started?
    return false if questionnaire.module_item.parent.first_confidence_page.nil?

    questionnaire.module_item.parent.first_confidence_page.name == params[:id]
  end

  def confidence_untracked?
    untracked?('confidence_check_start', training_module_id: params[:training_module_id])
  end

  def questionnaire
    @questionnaire ||= Questionnaire.find_by!(name: params[:id], training_module: params[:training_module_id])
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

      if questionnaire.final_question?
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
    if track_confidence_check_started? && confidence_untracked?
      track('confidence_check_start')
    end

    if track_summative_assessment_started? && summative_untracked?
      track('summative_assessment_start')
    end
  end
end
