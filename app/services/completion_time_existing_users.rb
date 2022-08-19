class CompletionTimeExistingUsers < ModuleTimeToComplete
  def initialize(user:, modules:)
    super(user: user)
    @modules = modules
  end
  
private

  def set_instance_variables(training_module)
    @training_module = training_module[0]
    @end_page = training_module[1]
  end

  def default_training_modules
    @modules
  end

  # @return [Ahoy::Event]
  def module_event(event_name, page_name)
    user.events.where(name: event_name).where_properties(training_module_id: @training_module, id: page_name).first
  end

  # @return [Time]
  def module_start_time
    module_event('module_content_page', 'intro').nil? ? nil : module_event('module_content_page', 'intro').time
  end

  # @return [Time]
  def module_complete_time
    module_event('module_content_page', @end_page).nil? ? nil : module_event('module_content_page', @end_page).time
  end
end