class Training::ModulesController < Contentful::BaseController
  before_action :authenticate_registered_user!, only: :show

  # helper_method :mod # TODO: replace use of instance variables with helper methods throughout

  def index
    track('course_overview_page')
    @mods = Training::Module.ordered.reject(&:draft?)
  end

  def show
    track('module_overview_page')

    if mod.nil?
      redirect_to my_modules_path
    else
      @module_progress_bar  = ContentfulModuleProgressBarDecorator.new(progress)
      @module_progress      = ContentfulModuleOverviewDecorator.new(progress)
      @assessment_progress  = assessment

      render partial: 'progress' if debug?
    end
  end

protected

  def debug?
    params[:debug] && Rails.application.debug?
  end

  def mod
    @mod ||= Training::Module.by_name(params[:id])
  end

  def progress
    @progress ||= helpers.cms_module_progress(mod)
  end

  def assessment
    @assessment ||= helpers.cms_assessment_progress(mod)
  end
end
