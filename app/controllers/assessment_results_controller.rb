class AssessmentResultsController < ApplicationController
  before_action :authenticate_registered_user!, :clear_flash, :show_progress_bar
  after_action :track_events, only: :show

  def new
    helpers.assessment_progress(training_module).archive_attempt
    redirect_to training_module_content_page_path(training_module, training_module.assessment_intro_page)
  end

  def show
    @assessment = helpers.assessment_progress(training_module)
    @module_item = ModuleItem.find_by(training_module: params[:training_module_id], name: params[:id])
  end

private

  def show_progress_bar
    @module_progress_bar = ModuleProgressBarDecorator.new(helpers.module_progress(training_module))
  end

  def training_module
    @training_module ||= TrainingModule.find_by(name: params[:training_module_id])
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
