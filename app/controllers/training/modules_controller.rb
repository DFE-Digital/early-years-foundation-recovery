class Training::ModulesController < Training::BaseController
  def index
    @published_modules = Training::Module.all.load
  end

  def show
    #track('module_overview_page')
    @training_module = Training::Module.find_by(slug: params[:id]).load.first

    @module_progress = ModuleOverviewDecorator.new(helpers.module_progress(@training_module))
    @module_progress = @training_module
    @assessment_progress = helpers.assessment_progress(@training_module)

    render partial: 'progress' if params[:debug] && Rails.env.development?
  end
end