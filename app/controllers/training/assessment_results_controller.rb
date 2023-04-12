module Training
  class AssessmentResultsController < ApplicationController
    before_action :authenticate_registered_user!
    after_action :track_events, only: :show

    helper_method :mod,
                  :content,
                  :progress_bar,
                  :assessment_progress

    # TODO: retire these helpers
    helper_method :module_item, :training_module

    def new
      helpers.cms_assessment_progress(mod).archive
      redirect_to training_module_page_path(mod_name, mod.assessment_intro_page.name)
    end

    def show
      # @assessment = helpers.cms_assessment_progress(mod)
      # @module_item = content
    end

  private

    # TODO: deprecate these ------------------------------------------------------

    def training_module
      mod
    end

    def module_item
      @module_item ||= content
    end

    # show -------------------

    def progress_bar
      ContentfulModuleProgressBarDecorator.new(progress)
    end

    def assessment_progress
      helpers.cms_assessment_progress(mod)
    end

    def progress
      helpers.cms_module_progress(mod)
    end

    def training_module
      mod
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
