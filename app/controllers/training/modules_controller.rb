class Training::ModulesController < ApplicationController
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

    if redirect?
      redirect_to my_modules_path
    elsif debug?
      render partial: 'progress'
    end
  end

protected

  # @return [Boolean]
  def redirect?
    mod.nil? || (!Rails.application.preview? && mod.draft?) || (Rails.application.preview? && !mod.pages?)
  end

  # @return [Boolean]
  def debug?
    params[:debug].present? && Rails.application.debug?
  end

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

  # @return [Training::Module]
  def mod
    Training::Module.by_name(params[:id])
  end

  def progress
    helpers.cms_module_progress(mod)
  end

  def assessment_progress
    helpers.assessment_progress(mod)
  end
end
