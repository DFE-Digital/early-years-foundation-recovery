module DataAnalysis
  class UsersStartedNotCompletedByExperience
    include ToCsv

    class << self
      # CSV headers
      def column_names
        %w[Experience ModuleName StartedNotCompleted Completed]
      end

      def dashboard
        #  Map each user to their module completion status
        per_user_module_status = all_users.flat_map do |user|
          user.module_time_to_completion.map do |module_name, completed_at|
            {
              experience: user.early_years_experience,
              module_name: module_name,
              started_not_completed: completed_at.nil? ? 1 : 0,
              completed: completed_at.present? ? 1 : 0,
            }
          end
        end

        # Group by experience and module_name
        grouped = per_user_module_status.group_by do |row|
          [row[:experience], row[:module_name]]
        end

        # Sum counts for started_not_completed and completed
        grouped.map do |(experience, module_name), entries|
          {
            experience: experience,
            module_name: module_name,
            started_not_completed: entries.sum { |e| e[:started_not_completed] },
            completed: entries.sum { |e| e[:completed] },
          }
        end
      end

    private

      # Only active users with an experience level
      def all_users
        User.where(closed_at: nil).where.not(early_years_experience: nil)
      end
    end
  end
end
