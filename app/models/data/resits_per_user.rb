module Data
  class ResitsPerUser
    include ToCsv
    include Percentage

    def self.to_csv
      user_roles = User.pluck(:id, :role_type).to_h
      headers = ['Module', 'User ID', 'Role', 'Resit Attempts']
      data = resit_attempts_per_user.flat_map do |module_name, user_attempts|
        user_attempts.map do |user_id, attempts|
          role_type = user_roles[user_id]
          [module_name, user_id, role_type, attempts]
        end
      end
      format_percentages(data)
      generate_csv(headers, data)
    end

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