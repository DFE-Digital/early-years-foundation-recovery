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
        Training::Module.live.map do |mod|
          {
            module_name: mod.name,
            count: still_failed(mod),
          }
        end
      end

    private

      # @param mod [Training::Module]
      # @return [Integer]
      def still_failed(mod)
        passed_user_ids = Assessment.passed.where(training_module: mod.name).pluck(:user_id)

        Assessment.failed
          .where(training_module: mod.name)
          .where.not(user_id: passed_user_ids)
          .pluck(:user_id).uniq.count
      end
    end
  end
end
