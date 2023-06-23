module Data
  class RolePassRate
    include ToCsv

    # @return [Array<String>]
    def self.column_names
      ['Role', 'Average Pass Percentage', 'Pass Count', 'Average Fail Percentage', 'Fail Count']
    end

    # @return [Hash{Symbol => Array}]
    def self.dashboard
      result = []
      SummativeQuiz.attribute_pass_percentage(:role_type).each do |role_type, percentages|
        pass_percentage = percentages[:pass_percentage]
        pass_count = percentages[:pass_count]
        fail_percentage = percentages[:fail_percentage]
        fail_count = percentages[:fail_count]
    
        result << {
          role_type: role_type,
          pass_percentage: pass_percentage,
          pass_count: pass_count,
          fail_percentage: fail_percentage,
          fail_count: fail_count
        }
      end
    
      result
    end
  end
end

