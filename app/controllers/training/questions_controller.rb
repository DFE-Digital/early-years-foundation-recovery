# Question flavours:
#
#   Tests:
#     - formative    (immediate result and not editable)
#     - summative    (grouped by assessment)
#
#   Opinions:
#     - confidence   (static options)
#     - feedback     (dynamic options)
#
#
module Training
  class QuestionsController < ApplicationController
    include Learning

    before_action :authenticate_registered_user!
    before_action :track_events, only: :show

    helper_method :mod,
                  :content,
                  :section_bar,
                  :current_user_response

    layout 'hero'

    def show
      log_caching { render :show }
    end

  private

    # @see Tracking
    # @return [Event] Show action
    def track_events
      if track_feedback_start?
        track('feedback_start')
      elsif track_feedback_complete?
        track('feedback_complete')
      elsif track_confidence_start?
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
    def track_feedback_start?
      content.first_feedback? && feedback_start_untracked?
    end

    # @return [Boolean]
    def track_feedback_complete?
      content.last_feedback? && feedback_complete_untracked?
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

    # @return [Boolean]
    def feedback_start_untracked?
      untracked?('feedback_start', training_module_id: mod.name)
    end

    # @return [Boolean]
    def feedback_complete_untracked?
      untracked?('feedback_complete', training_module_id: mod.name)
    end
  end
end
