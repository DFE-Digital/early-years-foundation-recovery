module DataAnalysis
  class UsersStartedNotCompletedByExperience
    include ToCsv

    class << self
      def column_names
        %w[ModuleName Experience UserCount]
      end

      def dashboard
        per_user_module_status
          .group_by { |row| [row[:module_name], row[:experience]] }
          .map { |(module_name, experience), rows|
            {
              module_name: module_name,
              experience: experience,
              user_count: rows.size,
            }
          }
          .sort_by { |h| [h[:module_name], h[:experience]] }
      end

    private

      def all_users
        User.where(closed_at: nil)
      end

      def per_user_module_status
        all_users.flat_map do |user|
          not_completed_modules(user).map do |module_name|
            {
              module_name: module_name,
              experience: user.early_years_experience || 'Unknown',
            }
          end
        end
      end

      def not_completed_modules(user)
        user.module_time_to_completion
            .select { |_module, time_spent| time_spent.to_i.zero? }
            .keys
      end
    end
  end
end
