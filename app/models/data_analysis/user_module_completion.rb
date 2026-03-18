module DataAnalysis
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
        registration_complete_user_ids = User.registration_complete.pluck(:id)
        Training::Module.ordered.reject(&:draft?).map do |mod|
          completed_count = UserModuleProgress.completed.where(module_name: mod.name, user_id: registration_complete_user_ids).count
          {
            module_name: mod.name,
            completed_count: completed_count,
            completed_percentage: (completed_count / registration_complete_user_ids.size.to_f),
          }
        end
      end

    private

      # @param mod_name [String]
      # @return [Integer]
      def module_count(mod_name)
        User.registration_complete.count { |user| user.module_completed?(mod_name) }
      end
    end
  end
end
