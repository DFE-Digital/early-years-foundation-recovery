module DataAnalysis
  class UsersNotPassing
    include ToCsv

    class << self
      # @return [Array<String>]
      def column_names
        [
          'Module',
          'Total Users Not Passing',
        ]
      end

      # @return [Array<Hash{Symbol => Mixed}>]
      def dashboard
        unpassed_assessments.group_by { |(mod, _), _| mod }.map do |mod, users|
          {
            module_name: mod,
            count: users.count,
          }
        end
      end

    private

      # @return [Hash{Array => Integer}]
      def all_failures
        Assessment.where(passed: false).group(:training_module, :user_id).count
      end

      # @param user_id [Integer]
      # @param training_module [String]
      # @return [Boolean]
      def eventually_passed?(training_module, user_id)
        Assessment.where(training_module: training_module, user_id: user_id, passed: true).any?
      end

      # @return [Hash{String => Integer}]
      def unpassed_assessments
        all_failures.reject { |attempt, _| eventually_passed?(*attempt) }
      end
    end
  end
end
