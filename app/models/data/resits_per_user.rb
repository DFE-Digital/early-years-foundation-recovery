module Data
  class ResitsPerUser
    include ToCsv

    class << self
      # @return [Array<String>]
      def column_names
        ['Module', 'User ID', 'Role', 'Resit Attempts']
      end

      # @return [Array<Hash{Symbol => Mixed}>]
      def dashboard
        resit_attempts_per_user.flat_map do |module_name, user_attempts|
          user_attempts.map do |user_id, attempts|
            {
              module_name: module_name,
              user_id: user_id,
              role_type: user_roles[user_id],
              resit_attempts: attempts,
            }
          end
        end
      end

  private

      # @return [Hash{Integer => String}]
      def user_roles
        User.pluck(:id, :role_type).to_h
      end

      # @return [Hash{Symbol => Hash{Integer => Integer}}]
      def resit_attempts_per_user
        UserAssessment.summative
          .group(:module, :user_id)
          .count
          .each_with_object({}) do |((module_name, user_id), count), resit_attempts_per_module|
            if count > 1
              resit_attempts_per_module[module_name] ||= {}
              resit_attempts_per_module[module_name][user_id] = count - 1
            end
          end
      end
  end
  end
end
