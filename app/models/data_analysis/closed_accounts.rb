module DataAnalysis
  class ClosedAccounts
    include ToCsv

    class << self
      # @return [Array<String>]
      def column_names
        [
          'User ID',
          'Closed',
          'Setting',
          'Custom setting',
          'Role',
          'Custom role',
          'Reason',
          'Custom reason',
        ]
      end

      # @return [Enumerator<Hash{Symbol => Mixed}>]
      def dashboard(batch_size: 1000, &block)
        results = []
        User.closed.find_each(batch_size: batch_size) do |user|
          row = {
            user_id: user.id,
            closed_at: user.closed_at.strftime('%Y-%m-%d %H:%M:%S'),
            setting_type: user.setting_type,
            setting_type_other: user.setting_type_other,
            role_type: user.role_type,
            role_type_other: user.role_type_other,
            closed_reason: user.closed_reason,
            closed_reason_custom: user.closed_reason_custom,
          }
          block ? block.call(row) : results << row
        end
        block ? nil : results
      end
    end
  end
end
