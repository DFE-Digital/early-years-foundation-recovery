module Data
  class ReturningUsers
    include ToCsv

    class << self
      # @return [Array<String>]
      def column_names
        [
          'Weekly Returning Users',
          'Monthly Returning Users',
          'Bimonthly Returning Users',
          'Quarterly Returning Users',
        ]
      end

      # @return [Array<Hash{Symbol => Mixed}>]
      def dashboard
        [
          {
            weekly: weekly,
            monthly: monthly,
            bimonthly: bimonthly,
            quarterly: quarterly,
          },
        ]
      end

    private

      # @param previous [Range]
      # @param current [Range]
      # @return [Integer]
      def count(previous:, current:)
        previous_visits = Ahoy::Visit.where(started_at: previous)
        current_visits = Ahoy::Visit.where(started_at: current)

        previous_visits.where(user_id: current_visits.pluck(:user_id)).distinct.count(:user_id)
      end

      # @return [Integer]
      def weekly
        count(previous: 2.weeks.ago..1.week.ago, current: 1.week.ago..Time.zone.now)
      end

      # @return [Integer]
      def monthly
        count(previous: 2.months.ago..1.month.ago, current: 1.month.ago..Time.zone.now)
      end

      # @return [Integer]
      def bimonthly
        count(previous: 4.months.ago..2.months.ago, current: 2.months.ago..Time.zone.now)
      end

      # @return [Integer]
      def quarterly
        current = Time.zone.today.beginning_of_quarter
        previous = current - 3.months
        count(previous: previous..current, current: current..Time.zone.today)
      end
    end
  end
end
