module Training
  class QuestionsController < ApplicationController
    before_action :authenticate_registered_user!
    before_action :track_events, only: :show

    helper_method :mod,
                  :content,
                  :progress_bar,
                  :current_user_response

    def show
      # TODO: deprecate these instance variables
      @module_item = content
    end

  protected

    # common content methods ----------------------------------------------------------------------------

    # @return [Training::Module] shallow
    def mod
      Training::Module.by_name(mod_name)
    end

    # @return [Training::Question]
    def content
      mod.page_by_name(content_name)
    end

    def progress
      helpers.cms_module_progress(mod)
    end

    def progress_bar
      ContentfulModuleProgressBarDecorator.new(progress)
    end

    # @return [String]
    def content_name
      params[:id]
    end

    # @return [String]
    def mod_name
      params[:training_module_id]
    end

    # response specific ----------------------------------------------------------------------------

    # @return [UserAnswer, Response]
    def current_user_response
      current_user.response_for(content)
    end

  private

    # @return [Ahoy::Event] Show action
    def track_events
      if track_confidence_start?
        track('confidence_check_start', cms: true)
      elsif track_assessment_start?
        track('summative_assessment_start', cms: true)
      end
    end

    # Check current item type for matching named event ---------------------------

    # @return [Boolean]
    def track_confidence_start?
      content.first_confidence? && confidence_start_untracked?
    end

    # @return [Boolean]
    def track_assessment_start?
      content.first_assessment? && summative_start_untracked?
    end

    # Check unique event is not already present ----------------------------------

    # @return [Boolean]
    def summative_start_untracked?
      untracked?('summative_assessment_start', training_module_id: mod.name)
    end

    # @return [Boolean]
    def confidence_start_untracked?
      untracked?('confidence_check_start', training_module_id: mod.name)
    end
  end
end
