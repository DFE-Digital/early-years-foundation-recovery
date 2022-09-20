# User's time taken to complete a module - calculated in seconds
#
class CalculateModuleState
  attr_reader :user

  def initialize(user:)
    @user = user
  end

  def call
    module_names.each do |training_module|
      current_value = user.module_time_to_completion[training_module]

      # do nothing - because time_to_completion has been calculated already
      next if current_value.to_i.positive?

      updated_value = new_time(training_module)

      unless updated_value == current_value
        user.module_time_to_completion[training_module] = updated_value
        user.save!
      end
    end
    # might need to reload to get latest change
    user.module_time_to_completion
  end

private

  # @param training_module [String]
  # @return [Integer] time in seconds
  def new_time(training_module)
    module_complete = mod_complete(training_module)
    module_start = mod_start(training_module)

    # 'in progress' => 'completed'
    if module_complete.present? && module_start.present?
      (module_complete.time - module_start.time).to_i
    # 'not started' => 'in progress'
    elsif module_start.present?
      0
    end
  end

  def module_names
    TrainingModule.all.reject(&:draft?).map(&:name)
  end

  def mod_event(training_module, event_name)
    user.events.where(name: event_name).where_properties(training_module_id: training_module).first
  end

  def mod_complete(training_module)
    mod_event(training_module, 'module_complete')
  end

  def mod_start(training_module)
    mod_event(training_module, 'module_start')
  end
end