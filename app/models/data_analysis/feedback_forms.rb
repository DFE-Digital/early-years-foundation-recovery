module DataAnalysis
  class FeedbackForms
    include ToCsv

    class << self
      # @return [Array<String>]
      def column_names
        [
          'Module',
          'Total Responses',
          'Signed in Users',
          'Guest Users',
        ]
      end

      # @return [Array<Hash>]
      def dashboard
        rows = Training::Module.ordered.map { |mod| feedback_for(mod.name, "properties ->> 'training_module_id' = ?") }
        rows << feedback_for('feedback', "properties ->> 'controller' = ?")
        rows
      end

    private

      # @param mod_name [String] the name of the module or "feedback" for site wide.
      # @param condition [String] the condition to filter the events.
      # @return [Hash]
      def feedback_for(mod_name, condition)
        events = complete_events.where(condition, mod_name.to_s)
        {
          mod: mod_name == 'feedback' ? 'site wide' : mod_name,
          total: events.count,
          signed_in: events.where.not(user_id: nil).count,
          guest: events.where(user_id: nil).count,
        }
      end

      # @return [ActiveRecord::Relation]
      def complete_events
        Event.where(name: 'feedback_complete')
      end
    end
  end
end
