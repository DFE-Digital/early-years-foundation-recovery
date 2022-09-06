class QuestionnairesController < ApplicationController
  before_action :authenticate_registered_user!

  def show
    # find the correct event when we merge with events pr

    one_session
    track_questionnaire
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

  def track_questionnaire
    track('module_questionnaire_formative_page') if questionnaire.formative?
    track('module_questionnaire_summative_page') if questionnaire.summative?
    track('module_questionnaire_confidence_page') if questionnaire.confidence?
  end

  def one_session
    if questionnaire.summative? && (assessment_flow.auth_summative_flow && !assessment_flow.passed)
      redirect_to assessment_flow.intro_page
    end

    if questionnaire.confidence?
      if assessment_flow.auth_confidence_flow && !assessment_flow.passed
        redirect_to assessment_flow.intro_page
      end
    end
  end

  def assessment_flow
    @assessment_flow ||= AssessmentFlow.new(user: current_user, type: questionnaire.assessments_type, mod: questionnaire.module_item.parent)
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
    end

    render :show, status: :unprocessable_entity
  end

  def next_question
    if unanswered?
      flash[:error] = 'Please select an answer'
      render :show, status: :unprocessable_entity
    else
      populate_and_persist

      redirect_to next_item_path(questionnaire.module_item)
    end
  end

  def marked_assessment
    if unanswered?
      flash[:error] = 'Please select an answer'
      render :show, status: :unprocessable_entity
    else
      populate_and_persist

      mod = questionnaire.module_item.parent

      if questionnaire.final_question?
        helpers.assessment_progress(mod).save!
        redirect_to training_module_assessment_result_path(mod, mod.assessment_results_page)
      else
        redirect_to next_item_path(questionnaire.module_item)
      end
    end
  end
end
