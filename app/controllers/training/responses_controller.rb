module Training
  class ResponsesController < ApplicationController
    before_action :authenticate_registered_user!
    before_action :track_events, only: :show

    helper_method :current_user_response,
                  :content,
                  :progress_bar

    # TODO: retire these helpers
    helper_method :module_item, :training_module


    # questions_controller
    def show
    end

    # responses_controller
    def update
      if current_user_response.update(answers: user_answers)
        track_questionnaire_answer
        redirect
      else
        render :show, status: :unprocessable_entity
      end
    end

  protected


    # TODO: deprecate these ------------------------------------------------------

    def training_module
      mod
    end

    def module_item
      @module_item ||= content
    end


    # common content methods ----------------------------------------------------------------------------

    # @return [Training::Module] shallow
    def mod
      Training::Module.by_name(mod_name)
    end

    # @return [Training::Content]
    def content
      mod.page_by_name(content_slug)
    end

    def progress
      helpers.cms_module_progress(mod)
    end

    def progress_bar
      ContentfulModuleProgressBarDecorator.new(progress)
    end

    # @return [String]
    def content_slug
      params[:id]
    end

    # @return [String]
    def mod_name
      params[:training_module_id]
    end

    # response specific ----------------------------------------------------------------------------

    # @return [Array<Integer>]
    def user_answers
      Array(response_params[:answers]).compact_blank.map(&:to_i)
    end

    def question_name
      content.name
    end

    def current_user_response
      current_user.responses.find_or_initialize_by(
        question_name: content_slug,
        training_module: mod_name,
        archive: false,
      )
    end

    def response_params
      params.require(:response).permit!
    end

  private

    def redirect
      if current_user_response.assess?
        ContentfulAssessmentProgress.new(user: current_user, mod: mod).save!
      end

      if content.formative_question?
        redirect_to training_module_response_path(mod_name, content_slug)
      else
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
            answers: current_user_response.answers)
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
