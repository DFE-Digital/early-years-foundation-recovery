class Training::ModulesController < Training::BaseController
  before_action :authenticate_registered_user!, only: :show

  def index
    track('course_overview_page')
    @published_modules = Training::Module.all.load
  end

  def show
    track('module_overview_page')
    @training_module = module_item = Training::Module.find_by(name: params[:id]).first

    # used for debug
    @module_progress_bar = ModuleProgressBarDecorator.new(helpers.module_progress(@training_module))

    if @training_module.nil?
      redirect_to my_modules_path
    else
      @module_progress = ModuleOverviewDecorator.new(helpers.module_progress(@training_module))
      @assessment_progress = helpers.assessment_progress(@training_module)

      render partial: 'progress' if params[:debug] && Rails.application.debug?
    end
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
