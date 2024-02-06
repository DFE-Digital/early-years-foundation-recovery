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
      if save_response! || (content.opinion_question? && content.options.blank?)
        track_question_answer
        redirect
      else
        if content.opinion_question? && user_answer_text.blank? && content.options.present?
          current_user_response.errors.clear
          current_user_response.errors.add :answers, :invalid
        end
        render 'training/questions/show', status: :unprocessable_entity
      end
    end

  private

    # @note migrate from user_answer to response
    # @see User#response_for
    def response_params
      if ENV['DISABLE_USER_ANSWER'].present?
        params.require(:response).permit!
      else
        params.require(:user_answer).permit!
      end
    end

    # @see User#response_for
    # @note migrate from user_answer to response
    # @return [Boolean]
    def save_response!
      correct_answers = content.confidence_question? || content.opinion_question? ? true : content.correct_answers.eql?(user_answers)

      question_answer =
        if content.opinion_question? && !user_answer_text.eql?(nil) && content.options.blank?
          [0]
        else
          user_answers
        end

      if ENV['DISABLE_USER_ANSWER'].present?
        current_user_response.update(answers: question_answer, correct: correct_answers, schema: content.schema, text_input: user_answer_text)
      else
        current_user_response.update(answer: user_answers, correct: correct_answers)
      end
    end

    # @return [Array<Integer>]
    def user_answers
      Array(response_params[:answers]).compact_blank.map(&:to_i)
    end

    def user_answer_text
      response_params[:text_input]
    end

    def redirect
      assessment.complete! if content.last_assessment?

      if content.formative_question?
        redirect_to training_module_question_path(mod.name, content.name)
      else
        redirect_to training_module_page_path(mod.name, content.next_item.name)
      end
    end

    # @return [Event] Update action
    def track_question_answer
      if ENV['DISABLE_USER_ANSWER'].present?
        track('questionnaire_answer',
              uid: content.id,
              mod_uid: mod.id,
              type: content.question_type,
              success: current_user_response.correct?,
              answers: current_user_response.answers,
              text_input: user_answer_text)
      else
        track('questionnaire_answer',
              uid: content.id,
              mod_uid: mod.id,
              type: content.assessments_type, # TODO: will be replaced with content.page_type
              success: current_user_response.correct?,
              answers: current_user_response.answers)
      end
    end
  end
end
