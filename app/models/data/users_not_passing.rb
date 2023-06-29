module Data
  class UsersNotPassing
    include ToCsv

    class << self
      # @return [Array<String>]
      def column_names
        ['Module', 'Total Users Not Passing']
      end

      # @return [Array<Hash{Symbol => Mixed}>]
      def dashboard
        total_users_not_passing_per_module.map do |module_name, count|
          {
            module_name: module_name,
            count: count
          }
        end
      end

  private

      # @return [Hash{String => Integer}]
      def total_users_not_passing_per_module
        UserAssessment.summative
          .group(:module, :user_id)
          .count
          .reject { |(module_name, user_id), _| UserAssessment.summative.where(module: module_name, user_id: user_id).passes.exists? }
          .group_by { |(module_name, _), _| module_name }
          .transform_values(&:size)
      end
  end
  end
end
