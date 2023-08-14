module Learning
  # ----------------------------------------------------------------------------
  # Request Params
  # ----------------------------------------------------------------------------

  # @return [String]
  def mod_name
    params[:training_module_id]
  end

  # @return [String]
  def content_name
    params[:id]
  end

  # ----------------------------------------------------------------------------
  # Contentful Entries
  # ----------------------------------------------------------------------------

  # @return [Training::Module]
  def mod
    Training::Module.by_name(mod_name)
  end

  # @return [Training::Page, Training::Video, Training::Question]
  def content
    mod.page_by_name(content_name)
  end

  # ----------------------------------------------------------------------------
  # Progress Services
  # ----------------------------------------------------------------------------

  # @return [AssessmentProgress]
  def assessment
    helpers.assessment_progress_service(mod)
  end

  # @return [ModuleProgress]
  def progress_service
    helpers.module_progress_service(mod)
  end

  # ----------------------------------------------------------------------------
  # Decorated Services
  # ----------------------------------------------------------------------------

  # @return [ModuleOverviewDecorator]
  def module_progress
    ModuleOverviewDecorator.new(progress_service)
  end

  # @return [ModuleProgressBarDecorator]
  def progress_bar
    ModuleProgressBarDecorator.new(progress_service)
  end

  # ----------------------------------------------------------------------------
  # Database Records
  # ----------------------------------------------------------------------------

  # @note memoization ensures validation errors work
  # @return [UserAnswer, Response]
  def current_user_response
    @current_user_response ||= current_user.response_for(content)
  end
end
