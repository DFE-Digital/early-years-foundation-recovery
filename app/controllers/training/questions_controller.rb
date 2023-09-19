module Training
  class QuestionsController < ApplicationController
    include Learning

    before_action :authenticate_registered_user!
    before_action :track_events, only: :show

    helper_method :mod,
                  :content,
                  :progress_bar,
                  :current_user_response

    def show; end

  private

    # @see Tracking
    # @return [Ahoy::Event] Show action
    def track_events
      if track_confidence_start?
        track('confidence_check_start')
      elsif track_assessment_start?
        track('summative_assessment_start')
      end
    end

    # @see Tracking
    # @return [Hash]
    def tracking_properties
      { uid: content.id, mod_uid: mod.id }
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
