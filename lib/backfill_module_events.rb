#
# Duplicate and rename a user's first and last page view events for a module:
#   1. module_start
#   2. module_complete
#
# Dependent on BackfillModuleState first populating the ttc
#
# @note deprecate BackfillModuleEvents and BackfillModuleState once used
#
require 'backfill_module_state'

class BackfillModuleEvents < BackfillModuleState
  def call
    user.module_time_to_completion.each do |training_module, ttc|
      if ttc.zero?
        clone_event training_module, 'module_start'
      elsif ttc.positive?
        clone_event training_module, 'module_start'
        clone_event training_module, 'module_complete'
      end
    end
  end

private

  def clone_event(training_module, event_name)
    if named_event(training_module, event_name)
      log "User [#{user.id}] #{event_name} event already present for #{training_module}"
      return
    end

    cloned_event = event_to_clone(training_module, event_name)

    unless cloned_event
      log "User [#{user.id}] #{event_name} event for #{training_module} cannot be cloned"
      return
    end

    cloned_event.name = event_name
    cloned_event.properties[:clone] = true
    cloned_event.save!

    log "User [#{user.id}] #{event_name} event created for #{training_module}"
  end

  # @return [Ahoy::Event, nil]
  def event_to_clone(training_module, event_name)
    case event_name
    when 'module_start'    then mod_start(training_module).dup
    when 'module_complete' then mod_complete(training_module).dup
    end
  end

  # @return [Ahoy::Event, nil]
  def named_event(training_module, event_name)
    user.events
      .where(name: event_name)
      .where_properties(training_module_id: training_module)
      .first
  end

  def log(message)
    if ENV['RAILS_LOG_TO_STDOUT'].present?
      Rails.logger.info(message)
    else
      puts message
    end
  end
end
