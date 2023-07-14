module Data
  class UserModuleCompletionCount
    include ToCsv

    class << self
      # @return [Array<String>]
      def column_names
        (1..module_count).map do |count|
          "#{count} Module#{count > 1 ? 's' : ''} Count"
        end
      end

      # @return [Array<Hash{Symbol => Mixed}>]
      def dashboard
        module_hash = {}
        (1..module_count).each do |count|
          module_hash[dashboard_key(count)] = module_completed_count(count)
        end
        [module_hash]
      end

    private

      # @return [Integer]
      def module_count
        Training::Module.ordered.count { |element| !element.draft? }
      end

      # @return [Symbol]
      def dashboard_key(count)
        "#{count} Module#{count > 1 ? 's' : ''} Count".to_sym
      end

      # @return [Integer]
      def module_completed_count(module_count)
        User.all.count { |user| user.modules_completed_count == module_count }
      end
    end
  end
end
