module DataAnalysis
  class UsersStartedNotCompletedByExperience
    include ToCsv

    class << self
      # CSV headers
      def column_names
        %w[ModuleName Experience UserCount]
      end

      def dashboard
        # Map each user to their module status (only not completed)
        per_user_module_status = all_users.flat_map do |user|
          user.module_time_to_completion.select { |_module, time_spent| time_spent.to_i.zero? }.map do |module_name, _time_spent|
            {
              module_name: module_name,
              experience: user.early_years_experience || 'Unknown',
            }
          end
        end

        # Group by module_name and experience, then count users
        per_user_module_status.group_by { |row| [row[:module_name], row[:experience]] }.map do |(module_name, experience), rows|
          {
            module_name: module_name,
            experience: experience,
            user_count: rows.size,
          }
        end.sort_by { |h| [h[:module_name], h[:experience]] }
      end

    private

      def all_users
        User.where(closed_at: nil)
      end
    end
  end
end
