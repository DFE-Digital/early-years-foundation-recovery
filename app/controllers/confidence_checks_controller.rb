class ConfidenceChecksController < AssessmentController
  def update
    questionnaire_taker.archive

    if unanswered?
      flash[:error] = 'Please select an answer'
      render :show, status: :unprocessable_entity
    else
      populate_and_persist

      redirect_to next_assessment_path(questionnaire.module_item)
    end
  end
end
