#
# TODO: Logic around potential FK question_name changes that could cause an assessment to contain more than 10 responses
# TODO: Checks that scores are numeric, otherwise zero is recorded
#
#
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
      if save_response! || (content.feedback_question? && content.options.blank?)
        track_question_answer
        redirect
      else
        if content.feedback_question? && user_answer_text.blank? && content.options.present?
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
      if Rails.application.migrated_answers?
        params.require(:response).permit!
      else
        params.require(:user_answer).permit!
      end
    end

    # @see User#response_for
    # @note migrate from user_answer to response
    # @return [Boolean]
    def save_response!
      correct_answers = content.confidence_question? || content.feedback_question? ? true : content.correct_answers.eql?(user_answers)

      if Rails.application.migrated_answers?
        current_user_response.update(answers: user_answers, correct: correct_answers, text_input: user_answer_text)
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
      assessment.grade! if content.last_assessment?

      if content.formative_question?
        redirect_to training_module_question_path(mod.name, content.name)
      else
        redirect_to training_module_page_path(mod.name, content.next_item.name)
      end
    end

    # @return [Event] Update action
    def track_question_answer
      if Rails.application.migrated_answers?
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
