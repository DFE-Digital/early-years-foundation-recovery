class SummativeAssessmentsController < AssessmentController
  def update
    questionnaire_taker.archive

    if unanswered?
      flash[:error] = 'Please select an answer'
      render :show, status: :unprocessable_entity
    else
      populate_and_persist

      mod = questionnaire.module_item.parent

      if questionnaire.final_question?
        helpers.assessment_progress(mod).save!
        redirect_to training_module_assessments_result_path(mod, mod.assessment_results_page)
      else
        redirect_to next_assessment_path(questionnaire.module_item)
      end
    end
  end
end
