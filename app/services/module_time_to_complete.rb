# User's time taken to complete a module - calculated in seconds
#
class ModuleTimeToComplete
  attr_reader :user
  
  def initialize(user:)
    @user = user
  end

  # @return [Hash{String => Integer}]
  def update_time(training_modules = default_training_modules)
    Array(training_modules).each do |training_module|
      
      set_instance_variables(training_module)
      return if module_start_time.nil?

      user.module_time_to_completion[@training_module] = result
      user.save if !result.nil?
      user.module_time_to_completion
    end
  end

private

  def set_instance_variables(training_module)
    @training_module = training_module
  end
  
  # @return [Integer] time in seconds
  def result
    return 0 if module_complete_time.nil?
    
    (module_complete_time - module_start_time).to_i
  end
  
  # @return [Array<String>]
  def default_training_modules
    TrainingModule.all.map do |training_module|
      training_module.name
    end
  end

  # @return [Ahoy::Event]
  def module_event(event_name)
    user.events.where(name: event_name).where_properties(training_module_id: @training_module).first
  end

  # @return [Time]
  def module_start_time
    module_event('module_start').nil? ? nil : module_event('module_start').time
  end

  # @return [Time]
  def module_complete_time
    module_event('module_complete').nil? ? nil : module_event('module_complete').time
  end
end
