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
      def dashboard(batch_size: 1000, &block)
        results = []
        ConfidenceCheckProgress.pre_check.skipped.order(:skipped_at).find_each(batch_size: batch_size) do |record|
          row = {
            user_id: record.user_id,
            training_module_skipped: record.module_name,
            timestamp: record.skipped_at,
          }
          block ? block.call(row) : results << row
        end
        block ? nil : results
      end
    end
  end
end
