module DataAnalysis
  class UsersCompletedModuleCountByExperience
    include ToCsv

    class << self
      # CSV headers
      def column_names
        %w[
          Experience
          ModulesCompleted
          UserCount
        ]
      end

      # Returns an array of hashes for CSV export
      def dashboard
        users = User
                  .where(closed_at: nil)
                  .pluck(:id, :early_years_experience, :module_time_to_completion)

        # Count completed modules per user
        counts_by_experience = users.each_with_object(Hash.new { |h, k| h[k] = Hash.new(0) }) do |(_id, experience, modules), h|
          completed_count = modules.values.count(&:present?)
          h[experience][completed_count] += 1
        end

        # Flatten to array of hashes for CSV export
        counts_by_experience.flat_map do |experience, counts|
          counts.map do |completed_count, user_count|
            {
              experience: experience,
              modules_completed: completed_count,
              user_count: user_count,
            }
          end
        end
      end
    end
  end
end
