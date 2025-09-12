module DataAnalysis
  class UsersCompletedModuleCountByExperience
    include ToCsv

    class << self
      def column_names
        %w[
          Experience
          ModulesCompleted
          UserCount
        ]
      end

      # Main entry point for CSV export
      def dashboard
        counts_by_experience.flat_map do |experience, counts|
          counts.map do |modules_completed, user_count|
            {
              experience: experience,
              modules_completed: modules_completed,
              user_count: user_count,
            }
          end
        end
      end

    private

      # Returns a hash of counts grouped by experience and completed modules
      def counts_by_experience
        all_users.each_with_object(Hash.new { |h, k| h[k] = Hash.new(0) }) do |user, h|
          h[user.early_years_experience][completed_modules_count(user)] += 1
        end
      end

      # Count of completed modules for a single user
      def completed_modules_count(user)
        user.module_time_to_completion.values.count(&:present?)
      end

      # Only active users
      def all_users
        User.not_closed
      end
    end
  end
end
