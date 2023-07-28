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
            weekly_returning_users: weekly_returning_users,
            monthly_returning_users: monthly_returning_users,
            quarterly_returning_users: quarterly_returning_users,
          },
        ]
      end

    private

      # @return [Integer]
      def weekly_returning_users
        current_week_visits = Ahoy::Visit.where(started_at: Time.zone.today.last_week.beginning_of_week..Time.zone.today.last_week.end_of_week)
        returning_users = current_week_visits.group(:user_id).having('count(user_id) > 1').count
        returning_users.count
      end

      # @return [Integer]
      def monthly_returning_users
        current_month_visits = Ahoy::Visit.where(started_at: Time.zone.today.last_month.beginning_of_month..Time.zone.today.last_month.end_of_month)
        returning_users = current_month_visits.group(:user_id).having('count(user_id) > 1').count
        returning_users.count
      end

      # @return [Integer]
      def quarterly_returning_users
        current_quarter_visits = Ahoy::Visit.where(started_at: Time.zone.today.beginning_of_quarter..Time.zone.today)
        returning_users = current_quarter_visits.group(:user_id).having('count(user_id) > 1').count
        returning_users.count
      end
    end
  end
end
