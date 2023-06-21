module Data
  class UsersNotPassing
    include ToCsv

    # @return [Array<String>]
    def self.column_names
      ['Module', 'Total Users Not Passing']
    end

    # @return [Hash{Symbol => Array}]
    def self.dashboard
      data = data_hash
      total_users_not_passing_per_module.map do |module_name, count|
        data[:module_name] << module_name
        data[:count] << count
      end
      data
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
