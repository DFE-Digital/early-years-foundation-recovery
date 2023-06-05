module Data
  class RolePassRate
    include ToCsv
    include Percentage

    def self.column_names
      ['Role', 'Average Pass Percentage', 'Pass Count', 'Average Fail Percentage', 'Fail Count']
    end

    def self.dashboard
      data = role_pass_percentage.map do |role_type, percentages|
        [role_type, percentages[:pass], percentages[:pass_count], percentages[:fail], percentages[:fail_count]]
      end
      format_percentages(data)
    end

    # @return [String]
    def self.to_csv
      generate_csv
    end

    # @return [Hash{Symbol => Hash{Symbol => Float, Integer}}]
    def self.role_pass_percentage
      SummativeQuiz.attribute_pass_percentage(:role_type)
    end
  end
end
