module Data
  class RolePassRate
    include ToCsv

    # @return [Array<String>]
    def self.column_names
      ['Role', 'Average Pass Percentage', 'Pass Count', 'Average Fail Percentage', 'Fail Count']
    end

    # @return [Hash{Symbol => Mixed}]
    def self.dashboard
      SummativeQuiz.attribute_pass_percentage(:role_type).map do |role_type, percentages|
        percentages[:type] = role_type
        percentages
      end
    end
  end
end
