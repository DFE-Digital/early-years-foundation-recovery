module Data
  class UserModuleCompletion
    include ToCsv

    class << self
      # @return [Array<String>]
      def column_names
        [
          'Module Name',
          'Completed Count',
          'Completed Percentage',
        ]
      end

      # @return [Array<Hash>]
      def dashboard
        Training::Module.ordered.reject(&:draft?).map do |mod|
          completed_count = module_count(mod.name)
          {
            module_name: mod.name,
            completed_count: completed_count,
            completed_percentage: (completed_count / User.count.to_f),
          }
        end
      end

    private

      # @param mod_name [String]
      # @return [Integer]
      def module_count(mod_name)
        User.all.count { |user| user.module_completed?(mod_name) }
      end
    end
  end
end
