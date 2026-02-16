# Question flavours:
#
#   Tests:
#     - formative    (immediate result and not editable)
#     - summative    (grouped by assessment)
#
#   Opinions:
#     - pre_confidence (static options)
#     - confidence     (static options)
#     - feedback       (dynamic options)
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
      elsif track_pre_confidence_start?
        record_pre_confidence_start
      elsif track_pre_confidence_complete?
        record_pre_confidence_complete
      elsif track_confidence_start?
        track('confidence_check_start')
        record_confidence_start
      elsif track_confidence_complete?
        record_confidence_complete
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
    def track_pre_confidence_start?
      content.first_pre_confidence? && !pre_confidence_recorded_start?
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

    # Confidence check progress tracking ----------------------------------------

    # @return [Boolean]
    def track_pre_confidence_complete?
      content.last_pre_confidence? && !pre_confidence_recorded_complete?
    end

    # @return [Boolean]
    def track_confidence_complete?
      content.last_confidence? && !confidence_recorded_complete?
    end

    # @return [Boolean]
    def pre_confidence_recorded_start?
      current_user.confidence_check_progress.where.not(started_at: nil).exists?(module_name: mod.name, check_type: 'pre')
    end

    # @return [Boolean]
    def pre_confidence_recorded_complete?
      current_user.confidence_check_progress.where.not(completed_at: nil).exists?(module_name: mod.name, check_type: 'pre')
    end

    # @return [Boolean]
    def confidence_recorded_complete?
      current_user.confidence_check_progress.where.not(completed_at: nil).exists?(module_name: mod.name, check_type: 'post')
    end

    def record_pre_confidence_start
      ConfidenceCheckProgress.record_start(user: current_user, module_name: mod.name, check_type: 'pre')
    end

    def record_pre_confidence_complete
      ConfidenceCheckProgress.record_completion(user: current_user, module_name: mod.name, check_type: 'pre')
    end

    def record_confidence_start
      ConfidenceCheckProgress.record_start(user: current_user, module_name: mod.name, check_type: 'post')
    end

    def record_confidence_complete
      ConfidenceCheckProgress.record_completion(user: current_user, module_name: mod.name, check_type: 'post')
    end
  end
end
