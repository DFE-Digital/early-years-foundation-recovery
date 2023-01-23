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
end