class FormativeAssessmentsController < AssessmentController
  def update
    questionnaire_taker.archive

    if unanswered?
      flash[:error] = 'Please select an answer'
    else
      populate_and_persist
    end

    render :show, status: :unprocessable_entity
  end
end
