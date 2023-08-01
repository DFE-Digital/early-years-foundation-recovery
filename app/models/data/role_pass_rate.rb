module Data
  class RolePassRate
    include ToCsv

    class << self
      # @return [Array<String>]
      def column_names
        [
          'Role',
          'Pass Percentage',
          'Pass Count',
          'Fail Percentage',
          'Fail Count',
        ]
      end

      # @return [Array<Hash{Symbol => Mixed}>]
      def dashboard
        SummativeQuiz.pass_rate(:role_type).map do |role_type, percentages|
          { role_type: role_type, **percentages }
        end
      end
    end
  end
end
