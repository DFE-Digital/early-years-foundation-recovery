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

      # Fetches all assessments and groups them by user
      # def all_ordered_accesses
      #   assessments = Assessment
      #                   .includes(:user)                    # eager load users to avoid N+1 queries
      #                   .where(users: { closed_at: nil })   # only include active users
      #                   .order('users.id ASC, assessments.started_at ASC') # order modules by start time per user

      #   assessments.group_by(&:user_id) # returns a hash: { user_id => [assessment1, assessment2, ...] }
      # end

      def all_ordered_accesses
        User.not_closed.includes(:assessments).order(:id).to_h do |user|
          [user.id, user.assessments]
        end
      end
    end
  end
end
