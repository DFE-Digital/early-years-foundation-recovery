module Data
  class RolePassRate
    include ToCsv

    # @return [Array<String>]
    def self.column_names
      ['Role', 'Average Pass Percentage', 'Pass Count', 'Average Fail Percentage', 'Fail Count']
    end

    # @return [Hash{Symbol => Mixed}]
     def self.dashboard
      data = SummativeQuiz.attribute_pass_percentage(:role_type).map do |role_type, percentages|
        [role_type] + percentages.values
      end
      keys = [ :type, :pass_percentage, :pass_count, :fail_percentage, :fail_count]
      keys.zip(data.transpose).to_h.transform_values(&:flatten)
    end

  end
end
