class Training::ModulesController < Training::BaseController
  before_action :authenticate_registered_user!, only: :show
  before_action :disable_cms_preview!, only: :index

  def index
    track('course_overview_page')
    @mods = Training::Module.all.load!
  end

  def show
    track('module_overview_page')

    if mod.nil?
      redirect_to my_modules_path
    else
      @mod = mod
      # used for debug
      @module_progress_bar  = ModuleProgressBarDecorator.new(progress)
      @module_progress      = ModuleOverviewDecorator.new(progress)
      @assessment_progress  = assessment

      # OPTIMIZE: instantiation of module_item
      # module_item

      render partial: 'progress' if debug?
    end
  end

protected

  def debug?
    (params[:debug] && Rails.application.debug?) || mod.draft?
  end

  def mod
    @mod ||= Training::Module.find_by(name: params[:id]).first
  end

  def progress
    @progress ||= helpers.module_progress(mod)
  end

  def assessment
    @assessment ||= helpers.assessment_progress(mod)
  end

  #   def module_item
  #     @module_item ||= ModuleItem.find_by(training_module: training_module_name, name: params[:id]) || ModuleItem.find_by(training_module: params[:id])
  #   end

  #   def training_module_name
  #     @training_module_name ||= params[:training_module_id]
  #   end
end
