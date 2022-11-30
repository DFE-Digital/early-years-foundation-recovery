#
# Duplicate and rename a user's first and last page view events for a module:
#   1. module_start
#   2. module_complete
#
# @note deprecate BackfillModuleEvents and BackfillModuleState once used
#
class BackfillModuleEvents < BackfillModuleState
  def call
    user.module_time_to_completion do |training_module, ttc|
      if ttc.zero?
        clone_start_event training_module
      elsif ttc.positive?
        clone_start_event training_module
        clone_complete_event training_module
      end
    end
  end

private

  def clone_start_event(training_module)
    event_name = 'module_start'
    return if named_event(training_module, event_name)

    mod_start(training_module).dup.update!(name: event_name)
  end

  def clone_complete_event(training_module)
    event_name = 'module_complete'
    return if named_event(training_module, event_name)

    mod_complete(training_module).dup.update!(name: event_name)
  end

  def named_event(training_module, event_name)
    user.events
      .where(name: event_name)
      .where_properties(training_module_id: training_module)
      .first
  end
end
