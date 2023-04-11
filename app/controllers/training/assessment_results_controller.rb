module Training
  class AssessmentResultsController < ApplicationController
    # include Contentfully

    before_action :authenticate_registered_user!, :show_progress_bar
    after_action :track_events, only: :show
    helper_method :training_module, :mod, :content

    def new
      helpers.cms_assessment_progress(mod).archive
      redirect_to training_module_page_path(mod_name, mod.assessment_intro_page.name)
    end

    def show
      @assessment = helpers.cms_assessment_progress(mod)
      @module_item = content
    end

  private

    def show_progress_bar
      @module_progress_bar = ContentfulModuleProgressBarDecorator.new(helpers.module_progress(training_module))
    end

    def training_module
      @training_module ||= mod
    end

    # @return [Boolean] pass not yet recorded
    def assessment_pass_untracked?
      untracked?('summative_assessment_complete',
                 training_module_id: params[:training_module_id],
                 success: true)
    end

    # Record the attempt result unless already passed
    # @return [Ahoy::Event, nil]
    def track_events
      return unless @assessment.attempted? && assessment_pass_untracked?

      track('summative_assessment_complete',
            type: 'summative_assessment',
            score: @assessment.score,
            success: @assessment.passed?)
    end
  end
end
