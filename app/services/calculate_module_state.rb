# User's time taken to complete a module
#
# Updates module_time_to_completion from user_module_progress table
#
class CalculateModuleState
  attr_reader :user

  def initialize(user:)
    @user = user
  end

  def call
    module_names.each do |training_module|
      current_value = user.module_time_to_completion[training_module]

      next if current_value.to_i.positive?

      updated_value = new_time(training_module)

      unless updated_value == current_value
        user.module_time_to_completion[training_module] = updated_value
        user.save!
      end
    end

    user.module_time_to_completion
  end

private

  # @param training_module [String]
  # @return [Integer] time in seconds
  def new_time(training_module)
    progress = UserModuleProgress.find_by(user: user, module_name: training_module)

    return nil unless progress&.started_at

    # 'in progress' => 'completed'
    if progress.completed_at.present?
      (progress.completed_at - progress.started_at).to_i
    # 'not started' => 'in progress'
    else
      0
    end
  end

  # @return [Array<String>]
  def module_names
    Training::Module.ordered.reject(&:draft?).map(&:name)
  end
end
