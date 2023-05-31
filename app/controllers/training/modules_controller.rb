class Training::ModulesController < ApplicationController
  before_action :authenticate_registered_user!, only: :show

  helper_method :mod,
                :progress_bar,
                :module_progress,
                :assessment_progress,
                :mods

  def index
    track('course_overview_page', cms: true)
  end

  def show
    track('module_overview_page', cms: true)

    if redirect?
      redirect_to my_modules_path
    elsif debug?
      render partial: 'progress'
    end
  end

protected

  # @return [Boolean]
  def redirect?
    mod.nil? || unreleased? || wip?
  end

  # When authoring a new module the overview page will not be accessible until
  # the module has some content. This will generate an application error unless
  # the module content passes the data integrity check.
  #
  # @return [Boolean]
  def wip?
    Rails.application.preview? && !mod.pages?
  end

  # @return [Boolean]
  def unreleased?
    !Rails.application.preview? && mod.draft?
  end

  # @return [Boolean]
  def debug?
    params[:debug].present? && Rails.application.debug?
  end

  # index -------------------

  # @return [Array<Training::Module>]
  def mods
    Training::Module.ordered
  end

  # show -------------------

  def module_progress
    ContentfulModuleOverviewDecorator.new(progress)
  end

  def progress_bar
    ContentfulModuleProgressBarDecorator.new(progress)
  end

  # @return [String]
  def mod_name
    params[:id]
  end

  # @return [nil]
  def content_name
    # no op
  end

  # @return [Training::Module]
  def mod
    Training::Module.by_name(mod_name)
  end

  def progress
    helpers.cms_module_progress(mod)
  end

  def assessment_progress
    helpers.cms_assessment_progress(mod)
  end
end
