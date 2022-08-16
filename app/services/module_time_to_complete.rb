# User's time taken to complete a module - calculated in seconds
#
class ModuleTimeToComplete
  def initialize(user:, training_module_id:)
    @user = user
    @training_module_id = training_module_id
  end

  attr_reader :user
  attr_accessor :training_module_id

  # @return [Hash{String => Integer}]
  def update_time(training_module_id)
    @training_module_id = training_module_id
    user.module_time_to_completion[training_module_id] = result
    user.save if !result.nil?
    user.module_time_to_completion
  end

  # @return [Integer] time in seconds
  def result
    return if module_complete_time.nil? && module_start_time.nil?
    
    return 0 if module_complete_time.nil?

    (module_complete_time - module_start_time).to_i
  end

private

  # @return [Time]
  def module_start_time
    first_event = user.events.where(name: 'module_start').where_properties(training_module_id: training_module_id).first
    first_event.nil? ? nil : first_event.time
  end

  # @return [Time]
  def module_complete_time
    first_event = user.events.where(name: 'module_complete').where_properties(training_module_id: training_module_id).first
    first_event.nil? ? nil : first_event.time
  end
end
