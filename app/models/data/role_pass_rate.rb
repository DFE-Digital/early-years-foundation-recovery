module Data
  class RolePassRate
    include ToCsv

    # @return [Array<String>]
    def self.column_names
      ['Role', 'Average Pass Percentage', 'Pass Count', 'Average Fail Percentage', 'Fail Count']
    end

    # @return [Hash{Symbol => Array}]
    def self.dashboard
      result = data_hash
      data = SummativeQuiz.attribute_pass_percentage(:role_type).map do |role_type, percentages|
        [role_type] + percentages.values
      end
      unless data.empty?
        result[:type] = data.transpose[0]
        result[:pass_percentage] = data.transpose[1]
        result[:pass_count] = data.transpose[2]
        result[:fail_percentage] = data.transpose[3]
        result[:fail_count] = data.transpose[4]
      end
      result
    end
  end
end
