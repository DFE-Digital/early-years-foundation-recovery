module DataAnalysis
  class UserLastInteraction
    include ToCsv

    WINDOW_DAYS = 90

    class << self
      # @return [Array<String>]
      def column_names
        [
          'User ID',
          'Email',
          'Registration Complete',
          'Last Interaction At',
        ]
      end

      # @return [Array<Hash{Symbol => Mixed}>]
      def dashboard
        cutoff = WINDOW_DAYS.days.ago

        events = Event.where.not(user_id: nil)
                      .where(time: cutoff..Time.zone.now)
                      .select('DISTINCT ON (user_id) user_id, time')
                      .order('user_id, time DESC')

        return [] if events.empty?

        user_ids = events.map(&:user_id)

        users = User.where(id: user_ids)
                    .select(:id, :email, :registration_complete)
                    .index_by(&:id)

        events.map { |event|
          user = users[event.user_id]
          next unless user

          {
            user_id: user.id,
            email: user.email,
            registration_complete: user.registration_complete,
            last_interaction_at: event.time,
          }
        }.compact
      end
    end
  end
end
