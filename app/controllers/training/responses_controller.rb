module Training
  class ResponsesController < ApplicationController
    include Learning

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
        render 'training/questions/show', status: :unprocessable_entity
      end
    end

  private

    # @note migrate from user_answer to response
    # @see User#response_for
    def response_params
      params.require(:response).permit!
    end

    # @see User#response_for
    # @note migrate from user_answer to response
    # @return [Boolean]
    def save_response!
      correct_answers = content.confidence_question? ? true : content.correct_answers.eql?(user_answers)

      current_user_response.update(answers: user_answers, correct: correct_answers)
    end

    # @return [Array<Integer>]
    def user_answers
      Array(response_params[:answers]).compact_blank.map(&:to_i)
    end

    def redirect
      assessment.grade! if content.last_assessment?

      if content.formative_question?
        redirect_to training_module_question_path(mod.name, content.name)
      else
        redirect_to training_module_page_path(mod.name, content.next_item.name)
      end
    end

    # @return [Event] Update action
    def track_question_answer
      track('questionnaire_answer',
            uid: content.id,
            mod_uid: mod.id,
            type: content.question_type,
            success: current_user_response.correct?,
            answers: current_user_response.answers)
    end
  end
end
