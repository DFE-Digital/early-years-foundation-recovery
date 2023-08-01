module Data
  class SummativeQuiz
    class << self
      # @param user_attribute [Symbol]
      # @return [Hash{Symbol => Hash}]
      def pass_rate(user_attribute)
        attribute_value_count = User.with_assessments.group(user_attribute).count

        attribute_value_count.transform_values do |total|
          value = attribute_value_count.key(total)
          pass = User.with_passing_assessments.where(user_attribute => value).count
          pass_fail(total: total, pass: pass)
        end
      end

      # @param total [Integer]
      # @param pass [Integer]
      # @return [Hash]
      def pass_fail(total:, pass:)
        pass_proportion = pass / total.to_f
        fail_proportion = 1 - pass_proportion

        {
          pass_percentage: pass_proportion,
          pass_count: pass,
          fail_percentage: fail_proportion,
          fail_count: total - pass,
        }
      end
    end
  end
end
