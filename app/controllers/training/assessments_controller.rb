module Training
  class AssessmentsController < ApplicationController
    before_action :authenticate_registered_user!
    after_action :track_events, only: :show

    helper_method :mod,
                  :content,
                  :progress_bar,
                  :assessment_progress

    def new
      helpers.cms_assessment_progress(mod).archive!
      redirect_to training_module_page_path(mod.name, mod.assessment_intro_page.name)
    end

    def show
      # TODO: deprecate these instance variables
      @module_item = content
    end

  private

    # @return [String]
    def content_name
      params[:id]
    end

    # @return [String]
    def mod_name
      params[:training_module_id]
    end

    # @return [Training::Question]
    def content
      mod.page_by_name(content_name)
    end

    # @return [Training::Module]
    def mod
      Training::Module.by_name(mod_name)
    end

    def progress_bar
      ContentfulModuleProgressBarDecorator.new(progress)
    end

    def assessment_progress
      helpers.cms_assessment_progress(mod)
    end

    def progress
      helpers.cms_module_progress(mod)
    end

    # @return [Boolean] pass not yet recorded
    def assessment_pass_untracked?
      untracked?('summative_assessment_complete',
                 training_module_id: mod.name,
                 success: true)
    end

    # Record the attempt result unless already passed
    # @return [Ahoy::Event, nil]
    def track_events
      return unless assessment_progress.attempted? && assessment_pass_untracked?

      track('summative_assessment_complete',
            type: 'summative_assessment',
            score: assessment_progress.score,
            success: assessment_progress.passed?)
    end
  end
end
