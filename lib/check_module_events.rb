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
