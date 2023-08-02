module Data
  class UserModuleCompletionCount
    include ToCsv

    class << self
      # @return [Array<String>]
      def column_names
        module_count.map { |count| "#{count} Completed" }
      end

      # @return [Array<Hash>]
      def dashboard
        [user_count]
      end

    private

      # @return [Hash {Symbol => Integer}]
      def user_count
        module_count.map { |count| [count.to_s.to_sym, completed_count(count)] }.to_h
      end

      # @return [Array<Integer>]
      def module_count
        (1..Training::Module.ordered.reject(&:draft?).last.position).to_a
      end

      # @param count [Integer]
      # @return [Integer]
      def completed_count(count)
        User.registration_complete.count { |user| user.modules_completed.eql?(count) }
      end
    end
  end
end
