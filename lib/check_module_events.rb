#
# This function returns true if the ttc of a user and their event history
# are in sync and either can be used to query module progress.
#
# TODO: `rake eyfs:report:stats` results should be aligned if this returns true
#       Delete this once production data has been rectified
#
# :nocov:
class CheckModuleEvents
  # @return [Boolean]
  def call
    User.all.all? do |user|
      user.module_time_to_completion.all? do |training_module, ttc|
        mod_events = user.events.where_properties(training_module_id: training_module)

        if ttc.nil?
          false # rerun BackfillModuleState
        elsif ttc.zero?
          mod_events.where(name: 'module_start').one?
        elsif ttc.positive?
          %w[module_start module_complete].all? do |named_event|
            mod_events.where(name: named_event).one?
          end
        end
      end
    end
  end
end
# :nocov:
