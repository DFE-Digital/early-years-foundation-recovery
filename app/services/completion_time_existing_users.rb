class CompletionTimeExistingUsers < ModuleTimeToComplete
  def initialize(user:, training_module_id:, start_page:, end_page:)
    super(user: user, training_module_id: training_module_id)
    @start_page = start_page
    @end_page = end_page
  end

  def module_start_time
    return nil if Ahoy::Event.where(user: @user, name: 'module_content_page')
      .where_properties(training_module_id: @training_module_id, id: @start_page).first.nil?
    
    Ahoy::Event.where(user: @user, name: 'module_content_page')
      .where_properties(training_module_id: @training_module_id, id: @start_page).first.time
  end

  def module_complete_time
    return nil if Ahoy::Event.where(user: @user, name: 'module_content_page')
      .where_properties(training_module_id: @training_module_id, id: @end_page).first.nil?
      
    Ahoy::Event.where(user: @user, name: 'module_content_page')
      .where_properties(training_module_id: @training_module_id, id: @end_page).first.time
  end
end