module Training
  class ResponsesController < Contentful::BaseController
    before_action :authenticate_registered_user!, :show_progress_bar, :module_item
    before_action :track_events, only: :show
    helper_method :training_module, :current_user_response, :content

    def show; end

    def update
      if current_user_response.update(answer: user_answer)
        track_questionnaire_answer
        redirect
      else
        render :show, status: :unprocessable_entity
      end
    end

  protected

    def user_answer
      answer = response_params[:answer]

      if answer.is_a?(Array)
        answer.compact_blank.map(&:to_i)
      else
        answer.present? ? answer.to_i : ''
      end
    end

    def show_progress_bar
      @module_progress_bar = ContentfulModuleProgressBarDecorator.new(helpers.cms_module_progress(mod))
    end

    def question_name
      content.name
    end

    def current_user_response
      @current_user_response ||= current_user.responses.find_or_initialize_by(
        question_name: content_slug,
        training_module: mod_name,
        archive: false,
      )
    end

    def response_params
      params.require(:response).permit!
    end

    def module_item
      @module_item ||= content
    end

  private

    def redirect
      if current_user_response.assess?
        ContentfulAssessmentProgress.new(user: current_user, mod: mod).save!
      end

      if content.formative?
        redirect_to training_module_response_path(mod_name, content_slug)
      else # content.confidence? || content.summative?
        redirect_to training_module_page_path(mod_name, content.next_item.name)
      end
    end

    # @return [Ahoy::Event] Show action
    def track_events
      if track_confidence_start?
        track('confidence_check_start')
      elsif track_assessment_start?
        track('summative_assessment_start')
      end
    end

    # @return [Ahoy::Event] Update action
    def track_questionnaire_answer
      track('questionnaire_answer',
            type: current_user_response.assessments_type,
            success: current_user_response.correct?,
            answer: current_user_response.answer)
    end

    # Check current item type for matching named event ---------------------------

    # @return [Boolean]
    def track_confidence_start?
      current_user_response.first_confidence? && confidence_start_untracked?
    end

    # @return [Boolean]
    def track_assessment_start?
      current_user_response.first_assessment? && summative_start_untracked?
    end

    # Check unique event is not already present ----------------------------------

    # @return [Boolean]
    def summative_start_untracked?
      untracked?('summative_assessment_start', training_module_id: params[:training_module_id])
    end

    # @return [Boolean]
    def confidence_start_untracked?
      untracked?('confidence_check_start', training_module_id: params[:training_module_id])
    end
  end
end
