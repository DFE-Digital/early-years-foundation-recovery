module Data
  class ModulesPerMonth
    include ToCsv

    class << self
      # @return [Array<String>]
      def column_names
        ['Month', 'Module', 'Pass Percentage', 'Pass Count', 'Fail Percentage', 'Fail Count']
      end

      # @return [Array<Hash{Symbol => Mixed}>]
      def dashboard
        grouped_assessments.flat_map do |month, module_data|
          module_data.flat_map do |module_name, assessments|
            { month: month, module_name: module_name }.merge(row_builder(assessments))
          end
        end
      end

  private

      # @return [Hash{Symbol => Mixed}]
      def row_builder(assessments)
        pass_count = assessments.count(&:passed?)
        total_count = assessments.size
        fail_count = total_count - pass_count
        pass_percentage = pass_count / total_count.to_f
        fail_percentage = 1 - pass_percentage

        {
          pass_percentage: pass_percentage,
          pass_count: pass_count,
          fail_percentage: fail_percentage,
          fail_count: fail_count,
        }
      end

      # @return [Hash{String => Array<UserAssessment>}}]
      def modules_by_month
        UserAssessment.summative.group_by { |assessment| assessment.created_at.strftime('%B %Y') }
      end

      # @return [Hash{String => Hash{String => Array<UserAssessment>}}]
      def grouped_assessments
        modules_by_month.transform_values { |assessments| assessments.group_by(&:module) }
      end
  end
  end
end
