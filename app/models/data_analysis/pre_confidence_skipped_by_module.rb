module DataAnalysis
  class PreConfidenceSkippedByModule
    include ToCsv

    class << self
      # @return [Array<String>]
      def column_names
        %w[
          user_id
          training_module_skipped
          timestamp
        ]
      end

      # @return [Array<Hash{Symbol => Mixed}>]
      def dashboard
        ConfidenceCheckProgress.pre_check.skipped.order(:skipped_at).map do |record|
          {
            user_id: record.user_id,
            training_module_skipped: record.module_name,
            timestamp: record.skipped_at,
          }
        end
      end
    end
  end
end
