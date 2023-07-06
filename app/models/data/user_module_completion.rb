module Data
  class UserModuleCompletion
    include ToCsv

    class << self
      # @return [Array<String>]
      def column_names
        headers = []
        Training::Module.ordered.reject(&:draft?).each do |mod|
          headers << "#{mod.name} Percentage"
          headers << "#{mod.name} Count"
        end
        headers
      end

      # @return [Array<Hash{Symbol => Mixed}>]
      def dashboard
        module_hash = {}
        Training::Module.ordered.reject(&:draft?).map do |mod|
          module_hash["#{mod.name}_percentage".to_sym] = module_count(mod.name) / User.count.to_f
          module_hash["#{mod.name}_count".to_sym] = module_count(mod.name)
        end
        [module_hash]
      end

    private

      # @return [Integer]
      def module_count(module_name)
        User.all.select { |user| user.module_time_to_completion.key?(module_name) && user.module_time_to_completion[module_name].positive? }.count
      end
    end
  end
end
