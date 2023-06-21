module Data
  class ResitsPerUser
    include ToCsv

    # @return [Array<String>]
    def self.column_names
      ['Module', 'User ID', 'Role', 'Resit Attempts']
    end

    # @return [Hash{Symbol => Array}]
    def self.dashboard
      user_roles = User.pluck(:id, :role_type).to_h
      data = Hash.new { |hash, key| hash[key] = [] }

      resit_attempts_per_user.each do |module_name, user_attempts|
        user_attempts.each do |user_id, attempts|
          data[:module_name] << module_name
          data[:user_id] << user_id
          data[:role_type] << user_roles[user_id]
          data[:resit_attempts] << attempts
        end
      end

      data
    end

    # @return [Hash{Symbol => Hash{Integer => Integer}}]
    def self.resit_attempts_per_user
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
