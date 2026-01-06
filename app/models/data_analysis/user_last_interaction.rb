module DataAnalysis
  class UserLastInteraction
    include ToCsv

    WINDOW_DAYS = 90

    class << self
      # @return [Array<String>]
      def column_names
        [
          'User ID',
          'Registration Complete',
          'Last Interaction At',
        ]
      end

      # @return [Array<Hash{Symbol => Mixed}>]
      def dashboard
        cutoff = WINDOW_DAYS.days.ago

        latest_responses = Response.where(created_at: cutoff..)
                                   .where.not(user_id: nil)
                                   .group(:user_id)
                                   .maximum(:created_at)

        latest_assessments = Assessment.where('COALESCE(completed_at, started_at) >= ?', cutoff)
                                       .where.not(user_id: nil)
                                       .group(:user_id)
                                       .maximum('COALESCE(completed_at, started_at)')

        latest_notes = Note.where(updated_at: cutoff..)
                           .where.not(user_id: nil)
                           .group(:user_id)
                           .maximum(:updated_at)

        user_ids = (latest_responses.keys + latest_assessments.keys + latest_notes.keys).uniq

        users = User.where(id: user_ids)
                    .select(:id, :registration_complete)
                    .index_by(&:id)

        user_ids.map { |user_id|
          user = users[user_id]
          next unless user

          times = [
            latest_responses[user_id],
            latest_assessments[user_id],
            latest_notes[user_id],
          ].compact

          max_time = times.map { |t| t.is_a?(String) ? Time.zone.parse(t) : t }.max

          {
            user_id: user.id,
            registration_complete: user.registration_complete,
            last_interaction_at: max_time,
          }
        }.compact.sort_by { |row| row[:last_interaction_at] }.reverse
      end
    end
  end
end
