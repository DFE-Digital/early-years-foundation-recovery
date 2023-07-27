module Data
  class UserModuleCompletion
    include ToCsv

    class << self
      # @return [Array<String>]
      def column_names
        %w[
          Module
          Count
          Percentage
        ]
      end

      # @return [Array<Hash{Symbol => Numeric}>]
      def dashboard
        Training::Module.ordered.reject(&:draft?).map do |mod|
          {
            module_name: mod.name,
            completed_count: module_count(mod.name),
            completed_percentage: (module_count(mod.name) / User.count.to_f),
          }
        end
      end

    private

      # @param module_name [String]
      # @return [Integer]
      def module_count(module_name)
        User.all.count { |user| user.module_completed?(module_name) }
      end
    end
  end
end
