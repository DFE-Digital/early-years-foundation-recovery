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
      if content.summative_question?
        nonce = params[:response] && params[:response][:submission_nonce]
        if nonce.present? && session[:form_nonce] == nonce
          if save_response!
            track_question_answer
            # Only consume nonce when assessment is completed (last question)
            session.delete(:form_nonce) if content.last_assessment?
            redirect
          else
            # On validation error, generate a new nonce for resubmission
            new_nonce = SecureRandom.uuid
            session[:form_nonce] = new_nonce
            @submission_nonce = new_nonce
            flash.now[:alert] = "DEBUG: session[:form_nonce]=#{session[:form_nonce]} params[:submission_nonce]=#{params[:response]&.[](:submission_nonce)} @submission_nonce=#{@submission_nonce}"
            render 'training/questions/show', status: :unprocessable_entity
          end
        else
          # If there are validation errors, show them (restore previous behavior)
          if current_user_response && current_user_response.errors.any?
            new_nonce = SecureRandom.uuid
            session[:form_nonce] = new_nonce
            @submission_nonce = new_nonce
            render 'training/questions/show', status: :unprocessable_entity
          else
            # Nonce already used or missing: ignore duplicate submission
            redirect_to training_module_question_path(mod.name, content.name), Rails.logger.error("Duplicate or invalid submission detected for user #{current_user.id} on question #{content.name}")
            # render plain: 'This form has already been submitted or is invalid.', status: :unprocessable_entity
          end
        end
      else
        # Formative and other questions: no nonce logic
        if save_response!
          track_question_answer
          redirect
        else
          render 'training/questions/show', status: :unprocessable_entity
        end
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
    rescue StandardError
      false
    end
  end
end
