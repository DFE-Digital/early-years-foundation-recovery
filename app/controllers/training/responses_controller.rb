module Training
  class ResponsesController < ApplicationController
    include Learning
    include Answering

    before_action :authenticate_registered_user!

    helper_method :mod,
                  :content,
                  :section_bar,
                  :current_user_response

    layout 'hero'

    def update
      if save_response!
        track_question_answer
        redirect
      else
        render 'training/questions/show', status: :unprocessable_content
      end
    end

  private

    def redirect
      assessment.grade! if content.last_assessment?

      if content.formative_question?
        redirect_to training_module_question_path(mod.name, content.name)
      else
        redirect_to training_module_page_path(mod.name, helpers.next_page.name)
      end
    end

    # @return [Event] Update action
    def track_question_answer
      track('questionnaire_answer',
            uid: content.id,
            mod_uid: mod.id,
            type: content.page_type,
            success: current_user_response.correct?,
            answers: current_user_response.answers)
    end
  end
end
