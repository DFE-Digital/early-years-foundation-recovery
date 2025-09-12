module DataAnalysis
  class UserModuleOrderByExperience
    include ToCsv

    class << self
      def column_names
        %w[
          Experience
          UserId
          ModuleName
          FirstAccessedAt
          Order
        ]
      end

      # Returns a "dashboard" hash array for export / visualization
      def dashboard
        # all_ordered_accesses returns a hash grouped by user_id
        grouped = all_ordered_accesses.map do |user_id, accesses|
          # accesses is an array of Assessment objects for that user
          accesses.each_with_index.map do |assessment, index|
            {
              experience: assessment.user.early_years_experience, # captures experience level
              user_id: user_id,                                   # user identifier
              module_name: assessment.training_module,           # which module was accessed
              first_accessed_at: assessment.started_at,          # timestamp of first access
              order: index + 1, # sequence order per user
            }
          end
        end
        grouped.flatten
      end

    private

      def all_ordered_accesses
        User.not_closed.includes(:assessments).order(:id).to_h do |user|
          [user.id, user.assessments]
        end
      end
    end
  end
end
