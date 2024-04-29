module DataAnalysis
  class ClosedAccounts
    include ToCsv

    class << self
      # @return [Array<String>]
      def column_names
        [
          'Closed',
          'Setting',
          'Custom setting',
          'Role',
          'Custom role',
          'Reason',
          'Custom reason',
        ]
      end

      # @return [Array<Hash{Symbol => Mixed}>]
      def dashboard
        User.closed.map do |user|
          {
            closed_at: user.closed_at.strftime('%Y-%m-%d %H:%M:%S'),
            setting_type: user.setting_type,
            setting_type_other: user.setting_type_other,
            role_type: user.role_type,
            role_type_other: user.role_type_other,
            closed_reason: user.closed_reason,
            closed_reason_custom: user.closed_reason_custom,
          }
        end
      end
    end
  end
end
