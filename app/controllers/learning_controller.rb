class LearningController < ApplicationController
  before_action :authenticate_registered_user!

  # helper_method :module_progress

  layout 'hero'

  # GET /my-modules
  def show
    @course = CourseProgress.new(current_user.events, current_user.assessments)

    track('learning_page')
  end

private

  # @return [ModuleOverviewDecorator]
  # def module_progress(mod)
  #   ModuleOverviewDecorator.new(helpers.module_progress_service(mod))
  # end
end
