class Training::ModulesController < Training::BaseController
  def index
    @published_modules = Training::Module.all.load
  end

  def show
    #track('module_overview_page')
    @training_module = Training::Module.find_by(name: params[:id])

    if @training_module.nil? || @training_module.draft?
      redirect_to my_modules_path
    else
      @module_progress = ModuleOverviewDecorator.new(helpers.module_progress(@training_module))
      @assessment_progress = helpers.assessment_progress(@training_module)

      # OPTIMIZE: instantiation of module_item
      module_item

      render partial: 'progress' if params[:debug] && Rails.env.development?
    end
  end
end