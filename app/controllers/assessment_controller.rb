class AssessmentController < ApplicationController
  before_action :authenticate_registered_user!

  def show
    questionnaire_taker.prepare
  end

protected

  def questionnaire
    @questionnaire ||= Questionnaire.find_by!(name: params[:id], training_module: params[:training_module_id])
  end

  def questionnaire_taker
    @questionnaire_taker ||= QuestionnaireTaker.new(user: current_user, questionnaire: questionnaire)
  end

  def next_assessment_path(item)
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
end
