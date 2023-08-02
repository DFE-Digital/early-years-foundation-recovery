module Data
  class ReturningUsers
    include ToCsv
    class << self
      # @return [Array<String>]
      def column_names
        ['Weekly Returning Users', 'Monthly Returning Users', 'Quarterly Returning Users']
      end

      # @return [Array<Hash{Symbol => Mixed}>]
      def dashboard
        [
          {
            weekly_returning_users: weekly,
            monthly_returning_users: monthly,
            quarterly_returning_users: quarterly,
          },
        ]
      end

    private

      # @param previous [Range]
      # @param current [Range]
      # @return [Integer]
      def count(time_range)
        visits = Ahoy::Visit.where(started_at: time_range)
        visits.group(:user_id).having('count(user_id) > 1').count.size
      end

      # @return [Integer]
      def weekly
        count(Time.zone.today.last_week.beginning_of_week..Time.zone.today.last_week.end_of_week)
      end

      # @return [Integer]
      def monthly
        count(Time.zone.today.last_month.beginning_of_month..Time.zone.today.last_month.end_of_month)
      end

      # @return [Integer]
      def quarterly
        current = Time.zone.today.beginning_of_quarter
        count(current..Time.zone.now)
      end
    end
  end
end
