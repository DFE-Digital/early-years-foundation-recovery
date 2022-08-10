# User's time taken to complete a module - calculated in seconds
#
class ModuleTimeToComplete
  def initialize(user:, training_module_id:)
    @user = user
    @training_module_id = training_module_id
  end

  attr_reader :user, :training_module_id

  # @return [Hash{String => Integer}]
  def update_time
    user.update!(module_time_to_completion: { training_module_id => result })
    user.module_time_to_completion
  end

  # @return [Integer] time in seconds
  def result
    (module_complete_time - module_start_time).to_i
  end

private

  # @return [Time]
  def module_start_time
    user.events.where(name: 'module_start').where_properties(training_module_id: training_module_id).first.time
  end

  # @return [Time]
  def module_complete_time
    user.events.where(name: 'module_complete').where_properties(training_module_id: training_module_id).first.time
  end
end
