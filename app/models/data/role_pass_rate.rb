module Data
  class RolePassRate
    include ToCsv

    class << self
      # @return [Array<String>]
      def column_names
        ['Role', 'Average Pass Percentage', 'Pass Count', 'Average Fail Percentage', 'Fail Count']
      end

      # @return [Array<Hash{Symbol => Mixed}>]
      def dashboard
        SummativeQuiz.attribute_pass_percentage(:role_type).map do |role_type, percentages|
          { role_type: role_type }.merge(percentages)
        end
      end
  end
  end
end
