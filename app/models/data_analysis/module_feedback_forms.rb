module DataAnalysis
  class ModuleFeedbackForms
    include ToCsv

    class << self
      # @return [Array<String>]
      def column_names
        %w[
          Module
          Started
          Completed
        ]
      end

      # @return [Array<Hash>]
      def dashboard
        Training::Module.live.map do |mod|
          {
            mod: mod.title,
            started: Event.where_module(mod.name).feedback_start.count,
            completed: Event.where_module(mod.name).feedback_complete.count,
          }
        end
      end
    end
  end
end
