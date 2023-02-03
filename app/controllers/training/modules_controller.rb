class Training::ModulesController < Contentful::BaseController
  # before_action :authenticate_registered_user!, only: :show

  def index
    track('course_overview_page')
    @mods = Training::Module.ordered.reject(&:draft?)
  end

  def show
    track('module_overview_page')

    if mod.nil?
      redirect_to my_modules_path
    else
      @module_progress_bar  = ModuleProgressBarDecorator.new(progress)
      @module_progress      = ContentfulModuleOverviewDecorator.new(progress)
      # @assessment_progress  = assessment

      render partial: 'progress' if debug?
    end
  end

protected

  def debug?
    (params[:debug] && Rails.application.debug?) || mod.draft?
  end

  def mod
    @mod ||= Training::Module.by_name(params[:id])
  end

  def progress
    @progress ||= helpers.cms_module_progress(mod)
  end

  # def assessment
  #   @assessment ||= helpers.assessment_progress(mod)
  # end
end
