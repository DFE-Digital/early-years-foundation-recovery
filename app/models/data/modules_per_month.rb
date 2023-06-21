module Data
  class ModulesPerMonth
    include ToCsv
    include Percentage

    # @return [Array<String>]
    def self.column_names
      ['Month', 'Module', 'Pass Percentage', 'Pass Count', 'Fail Percentage', 'Fail Count']
    end

    # @return [Hash{Symbol => Mixed}]
    def self.dashboard
      modules_by_month.each_with_object(Hash.new { |h, k| h[k] = [] }) do |(month, module_data), result|
        module_data.each do |module_name, assessments|
          pass_count = assessments.count(&:passed?)
          total_count = assessments.size
          fail_count = total_count - pass_count

          pass_percentage = calculate_percentage(pass_count, total_count)
          fail_percentage = 100 - pass_percentage

          result[:month] << month
          result[:module_name] << module_name
          result[:pass_percentage] << pass_percentage
          result[:pass_count] << pass_count
          result[:fail_percentage] << fail_percentage
          result[:fail_count] << fail_count
        end
      end
    end

    # @return [Hash{String => Hash{String => Array<UserAssessment>}}]
    def self.modules_by_month
      UserAssessment.summative.group_by { |assessment| assessment.created_at.strftime('%B %Y') }
                     .transform_values { |assessments_by_month| assessments_by_month.group_by(&:module) }
    end
  end
end
