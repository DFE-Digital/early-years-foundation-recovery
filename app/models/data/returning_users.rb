module Data
  class ReturningUsers
    include ToCsv
    class << self
      # @return [Array<String>]
      def column_names
        ['Weekly Returning Users', 'Monthly Returning Users', '2 Monthly Returning Users', 'Quarterly Returning Users']
      end

      # @return [Array<Hash{Symbol => Mixed}>]
      def dashboard
        [
          {
            weekly_returning_users: weekly_returning_users,
            monthly_returning_users: monthly_returning_users,
            two_monthly_returning_users: two_monthly_returning_users,
            quarterly_returning_users: quarterly_returning_users,
          },
        ]
      end

    private

      # @return [Integer]
      def weekly_returning_users
        previous_week_visits = Ahoy::Visit.where(started_at: 2.weeks.ago..1.week.ago)
        current_week_visits = Ahoy::Visit.where(started_at: 1.week.ago..Time.zone.now)
        returning_users = previous_week_visits.where(user_id: current_week_visits.pluck(:user_id))
        returning_users.distinct.count(:user_id)
      end

      # @return [Integer]
      def monthly_returning_users
        previous_month_visits = Ahoy::Visit.where(started_at: 2.months.ago..1.month.ago)
        current_month_visits = Ahoy::Visit.where(started_at: 1.month.ago..Time.zone.now)
        returning_users = previous_month_visits.where(user_id: current_month_visits.pluck(:user_id))
        returning_users.distinct.count(:user_id)
      end

      # @return [Integer]
      def two_monthly_returning_users
        previous_two_month_visits = Ahoy::Visit.where(started_at: 4.months.ago..2.months.ago)
        current_two_month_visits = Ahoy::Visit.where(started_at: 2.months.ago..Time.zone.now)
        returning_users = previous_two_month_visits.where(user_id: current_two_month_visits.pluck(:user_id))
        returning_users.distinct.count(:user_id)
      end

      # @return [Date]
      def current_quarter
        Time.zone.today.beginning_of_quarter
      end

      # @return [Date]
      def previous_quarter
        (current_quarter - 1.day).beginning_of_quarter
      end

      # @return [Integer]
      def quarterly_returning_users
        previous_quarter_visits = Ahoy::Visit.where(started_at: previous_quarter..current_quarter)
        current_quarter_visits = Ahoy::Visit.where(started_at: current_quarter..Time.zone.today)
        returning_users = previous_quarter_visits.where(user_id: current_quarter_visits.pluck(:user_id))
        returning_users.distinct.count(:user_id)
      end
    end
  end
end
