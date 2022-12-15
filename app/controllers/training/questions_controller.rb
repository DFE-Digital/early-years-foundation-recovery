class Training::QuestionsController < Training::BaseController
  before_action :authenticate_registered_user!, :module_item
  after_action :track_events, only: :show
  helper_method :question

  def show
    question_response.prepare
  end

  def update
    if unanswered?
      flash[:error] = 'Please select an answer'
      render :show, status: :unprocessable_entity
    else
      populate_and_persist
      track_question_answer
      redirect
    end
  end

protected

  def module_item
    @module_item ||= question.module_item
  end

  def question
    @question ||= Training::Question.find_by(slug: module_params[:id], module_id: module_params[:training_module_id]).first
  end

  def question_response
    @question_response ||= Training::QuestionResponse.new(user: current_user, question: question)
  end

  def question_params
    params.require(:training_question).permit!
  end

  def module_params
    params.permit(:training_module_id, :id)
  end

  def populate_and_persist
    question_response.populate(question_params)
    question_response.persist

    clear_flash
  end

  # return [Boolean]
  def unanswered?
    # radio_buttons
    return true unless params[:training_question]

    # check_boxes
    check_boxes = params[:training_question][question.id]
    Array(check_boxes).compact_blank.empty?
  end

private

  def redirect
    if question.formative?
      redirect_to training_module_question_path(module_item.training_module, module_item)

    elsif question.summative?
      helpers.assessment_progress(module_item.parent).save! if question.last_assessment?

      redirect_to training_module_content_page_path(module_item.training_module, module_item.next_item)

    elsif question.confidence?
      redirect_to training_module_content_page_path(module_item.training_module, module_item.next_item)
    end
  end

  def track_events
    if question.first_confidence? && confidence_untracked?
      track('confidence_check_start')
    end

    if question.first_assessment? && summative_untracked?
      track('summative_assessment_start')
    end
  end

  def summative_untracked?
    untracked?('summative_assessment_start', training_module_id: params[:training_module_id])
  end

  def confidence_untracked?
    untracked?('confidence_check_start', training_module_id: params[:training_module_id])
  end

  def track_question_answer
    key = question.keys.first

    track('questionnaire_answer',
          type: question.assessments_type,
          success: question.result_for(key),
          answer: question.answer_for(key))
  end
end
