module Data
  class UsersNotPassing
    include ToCsv
    include Percentage

    def self.column_names
      ['Module', 'Total Users Not Passing']
    end

    def self.dashboard
      data = total_users_not_passing_per_module.map { |module_name, total_users| [module_name, total_users] }
      format_percentages(data)
    end

    # @return [String]
    def self.to_csv
      generate_csv
    end

    # @return [Hash{String => Integer}]
    def self.total_users_not_passing_per_module
      UserAssessment.summative
        .group(:module, :user_id)
        .count
        .reject { |(module_name, user_id), _| UserAssessment.summative.where(module: module_name, user_id: user_id).passes.exists? }
        .group_by { |(module_name, _), _| module_name }
        .transform_values(&:size)
    end
  end
end
