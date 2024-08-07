module Training
  class AssessmentsController < ApplicationController
    include Learning

    before_action :authenticate_registered_user!
    after_action :track_events, only: :show

    helper_method :mod,
                  :content,
                  :section_bar,
                  :assessment

    layout 'hero'

    def show; end

  private

    # @return [Boolean] pass not yet recorded
    def assessment_pass_untracked?
      untracked?('summative_assessment_complete',
                 training_module_id: mod.name,
                 success: true)
    end

    # Record the attempt result unless already passed
    # @return [Event, nil]
    def track_events
      return unless assessment.attempted? && assessment_pass_untracked?

      track('summative_assessment_complete',
            type: 'summative_assessment',
            uid: content.id,
            mod_uid: mod.id,
            score: assessment.score,
            success: assessment.passed?)
    end
  end
end
