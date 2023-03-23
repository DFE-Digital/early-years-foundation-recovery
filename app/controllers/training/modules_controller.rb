class Training::ModulesController < Contentful::BaseController
  before_action :authenticate_registered_user!, only: :show

  helper_method :mod,
                :progress_bar,
                :module_progress,
                :assessment_progress,
                :mods

  def index
    track('course_overview_page')
  end

  def show
    track('module_overview_page')

    if mod.nil?
      redirect_to my_modules_path
    else
      render partial: 'progress' if debug?
    end
  end

protected
  # index -------------------

  def mods
    Training::Module.ordered.reject(&:draft?)
  end

  # show -------------------

  def module_progress
    ContentfulModuleOverviewDecorator.new(progress)
  end

  def progress_bar
    ModuleProgressBarDecorator.new(progress)
  end

  def mod
    Training::Module.by_name(params[:id])
  end

  def progress
    helpers.cms_module_progress(mod)
  end

  def assessment_progress
    helpers.assessment_progress(mod)
  end

  def debug?
    params[:debug] && Rails.application.debug?
  end
end
