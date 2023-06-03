module Data
  class RolePassRate
    include ToCsv
    include Percentage

    def self.to_csv
      headers = ['Role', 'Average Pass Percentage', 'Pass Count', 'Average Fail Percentage', 'Fail Count']
      data = role_pass_percentage.map do |role_type, percentages|
        [role_type, percentages[:pass], percentages[:pass_count], percentages[:fail], percentages[:fail_count]]
      end
      format_percentages(data)
      generate_csv(headers, data)
    end

    def self.role_pass_percentage
      SummativeQuiz.attribute_pass_percentage(:role_type)
    end
  end
end
