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
      def dashboard(batch_size: 1000)
        return enum_for(:dashboard, batch_size: batch_size) unless block_given?

        ConfidenceCheckProgress.pre_check.skipped.order(:skipped_at).find_each(batch_size: batch_size) do |record|
          yield({
            user_id: record.user_id,
            training_module_skipped: record.module_name,
            timestamp: record.skipped_at,
          })
        end
      end
    end
  end
end
