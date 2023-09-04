module Data
  class UserOverview
    include ToCsv

    class << self
      # @return [Array<String>]
      def column_names
        [
          'Registration Complete',
          'Registration Incomplete',
          'Reregistered',
          'Registered Since Private Beta',
          'Private Beta Only Registration Incomplete',
          'Private Beta Only Registration Complete',
          'Registration Events',
          'Private Beta Registration Events',
          'Public Beta Registration Events',
          'Total',
          'Locked Out',
          'Confirmed',
          'Unconfirmed',
          'User Defined Roles',
          'Started Learning',
          'Not Started Learning',
          'With Notes',
          'With Notes Percentage',
          'Without Notes',
          'Without Notes Percentage',
          'Complete Registration Mail Recipients',
          'Start Training Mail Recipients',
          'Continue Training Mail Recipients',
          'New Module Mail Recipients',
        ]
      end

      # @return [Array<Hash{Symbol => Mixed}>]
      def dashboard
        [{
          registration_complete: User.registration_complete.count,
          registration_incomplete: User.registration_incomplete.count,
          reregistered: User.reregistered.count,
          registered_since_private_beta: User.registered_since_private_beta.count,
          private_beta_only_registration_incomplete: User.private_beta_only_registration_incomplete.count,
          private_beta_only_registration_complete: User.private_beta_only_registration_complete.count,
          registration_events: Ahoy::Event.user_registration.count,
          private_beta_registration_events: Ahoy::Event.private_beta_registration.count,
          public_beta_registration_events: Ahoy::Event.public_beta_registration.count,
          total: User.all.count,
          locked_out: User.locked_out.count,
          confirmed: User.confirmed.count,
          unconfirmed: User.unconfirmed.count,
          user_defined_roles: User.all.collect(&:role_type_other).uniq.count,
          started_learning: started_learning,
          not_started_learning: not_started_learning,
          with_notes: with_notes_count,
          with_notes_percentage: with_notes_percentage,
          without_notes: without_notes_count,
          without_notes_percentage: 1 - with_notes_percentage,
          complete_registration_mail_recipients: User.complete_registration_recipients.count,
          start_training_mail_recipients: User.start_training_recipients.count,
          continue_training_mail_recipients: User.continue_training_recipients.count,
          new_module_mail_recipients: NewModuleMailJob.recipients.count,
        }]
      end

    private

      # @return [Float]
      def with_notes_percentage
        with_notes_count / User.count.to_f
      end

      # @return [Integer]
      def with_notes_count
        User.not_closed.with_notes.count
      end

      # @return [Integer]
      def without_notes_count
        User.not_closed.without_notes.count
      end

      # @note Ahoy::Event.module_start.distinct.count(:user_id)
      # @return [Integer]
      def started_learning
        User.all.count { |u| !u.module_time_to_completion.empty? }
      end

      # @return [Integer]
      def not_started_learning
        User.all.count { |u| u.module_time_to_completion.empty? }
      end
    end
  end
end
