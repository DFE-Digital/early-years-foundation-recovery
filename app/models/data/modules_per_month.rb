module Data
  class ModulesPerMonth
    include ToCsv
    include Percentage

    # @return [String]
    def self.to_csv
      headers = ['Month', 'Module', 'Pass Percentage', 'Pass Count', 'Fail Percentage', 'Fail Count']
      data = modules_by_month.flat_map do |month, module_data|
        module_data.map do |module_name, assessments|
          pass_count = assessments.count(&:passed?)
          total_count = assessments.size
          fail_count = total_count - pass_count

          pass_percentage = calculate_percentage(pass_count, total_count)
          fail_percentage = 100 - pass_percentage

          [month, module_name, pass_percentage, pass_count, fail_percentage, fail_count]
        end
      end
      format_percentages(data)
      generate_csv(headers, data)
    end

    # @return [Hash{String => Hash{String => Array<UserAssessment>}}]
    def self.modules_by_month
      UserAssessment.summative.group_by { |assessment| assessment.created_at.strftime('%B %Y') }
                     .transform_values { |assessments_by_month| assessments_by_month.group_by(&:module) }
    end
  end
end
