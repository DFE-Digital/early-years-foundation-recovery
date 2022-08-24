class QuestionnairesController < ApplicationController
  before_action :authenticate_registered_user!

  def show
    one_session
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
  def one_session
   assessment_flow =  AssessmentFlow.new(user: current_user, type: SUMMATIVE, mod: questionnaire.module_item.parent, request: request)
   redirect_to assessment_flow.intro_page if assessment_flow.authenticate_flow
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
