module DataAnalysis
  class UsersNotPassing
    include ToCsv

    class << self
      # @return [Array<String>]
      def column_names
        [
          'Module',
          'Total Users Not Passing',
        ]
      end

      # @return [Array<Hash{Symbol => Mixed}>]
      def dashboard
        total_users_not_passing_per_module.map do |module_name, count|
          {
            module_name: module_name,
            count: count,
          }
        end
      end

    private

      # @return [Hash{String => Integer}]
      def total_users_not_passing_per_module
        Assessment.all
          .group(:training_module, :user_id)
          .count
          .reject { |(module_name, user_id), _| Assessment.all.where(training_module: module_name, user_id: user_id).passed.exists? }
          .group_by { |(module_name, _), _| module_name }
          .transform_values(&:size)
      end
    end
  end
end
