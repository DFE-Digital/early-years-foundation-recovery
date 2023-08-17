module Data
  class UserModuleOrder
    include ToCsv

    class << self
      # @return [Array<String>]
      def column_names
        [
          'Following Linear Sequence',
          'Not Following Linear Sequence',
        ]
      end

      # @return [Array<Hash{Symbol => Integer}>]
      def dashboard
        [
          {
            linear_activity: linear_activity.count,
            non_linear_activity: non_linear_activity.count,
          },
        ]
      end

    private

      # @return [Array<Training::Module>]
      def mods
        Training::Module.ordered.reject(&:draft?)
      end

      # @return [Hash{String => Integer}]
      def content_order
        mods.map { |m| [m.name, m.position] }.to_h
      end

      # users that started a new module since we permitted jumping around
      # @return [Array<User>]
      def users
        User.find Ahoy::Event.module_start.since_non_linear.map(&:user_id)
      end

      # modules in order of activity for each user
      # @return [Array<Array>]
      def activity_by_position
        users.map do |user|
          content_order.slice(*user.module_time_to_completion.keys).values
        end
      end

      # @param numbers [Array<Integer>]
      # @return [Boolean]
      def in_order?(numbers)
        numbers.each_cons(2).all? { |a, b| (a + 1).eql?(b) }
      end

      # @return [Integer] users continuing to do modules in order
      def linear_activity
        activity_by_position.select { |numbers| in_order?(numbers) }
      end

      # @return [Integer] users stopped doing modules in order
      def non_linear_activity
        activity_by_position.reject { |numbers| in_order?(numbers) }
      end
    end
  end
end
