module Training
  class ResponsesController < ApplicationController
    include Learning
    include Pagination

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

    # @return [ActionController::Parameters]
    def response_params
      params.require(:response).permit!
    end

    # @return [Boolean]
    def save_response!
      current_user_response.update(
        answers: response_answers,
        correct: correct?,
        text_input: response_text_input,
      )
    end

    # @return [Boolean]
    def correct?
      content.opinion_question? ? true : content.correct_answers.eql?(response_answers)
    end

    # @return [Array<Integer>]
    def response_answers
      Array(response_params[:answers]).compact_blank.map(&:to_i)
    end

    # @return [String]
    def response_text_input
      response_params[:text_input]
    end

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
