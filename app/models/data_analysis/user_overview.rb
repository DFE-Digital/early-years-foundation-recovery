module DataAnalysis
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
          'GovOne',
          'User Defined Roles',
          'Started Learning',
          'Not Started Learning',
          'With Notes',
          'With Notes Percentage',
          'Without Notes',
          'Without Notes Percentage',
          'Training Mail Recipients',
          'Early Years Recipients',
          'Complete Registration Mail Recipients',
          'Start Training Mail Recipients',
          'Continue Training Mail Recipients',
          'New Module Mail Recipients',
          'Pre-prod Test Recipients',
          'Closed',
          'Terms and Conditions Agreed',
          'Received Mail Yesterday',
          'Received Mail Today',
          'User Email Success',
          'User Email Fail',
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
          registration_events: Event.user_registration.count,
          private_beta_registration_events: Event.private_beta_registration.count,
          public_beta_registration_events: Event.public_beta_registration.count,
          total: User.all.count,
          locked_out: User.locked_out.count,
          confirmed: User.confirmed.count,
          unconfirmed: User.unconfirmed.count,
          gov_one: User.gov_one.count,
          user_defined_roles: User.all.collect(&:role_type_other).uniq.count,
          started_learning: started_learning,
          not_started_learning: not_started_learning,
          with_notes: with_notes_count,
          with_notes_percentage: with_notes_percentage.round(2),
          without_notes: without_notes_count,
          without_notes_percentage: (1 - with_notes_percentage).round(2),
          training_mail_recipients: User.training_email_recipients.count,
          early_years_mail_recipients: User.early_years_email_recipients.count,
          complete_registration_mail_recipients: CompleteRegistrationMailJob.recipients.count,
          start_training_mail_recipients: StartTrainingMailJob.recipients.count,
          continue_training_mail_recipients: ContinueTrainingMailJob.recipients.count,
          new_module_mail_recipients: NewModuleMailJob.recipients.count,
          test_mail_recipients: TestBulkMailJob.recipients.count,
          closed: User.closed.count,
          terms_and_conditions_agreed: terms_and_conditions_agreed_count,
          mail_yesterday: User.email_delivered_days_ago(1).count,
          mail_today: User.email_delivered_today.count,
          mail_delivered: User.email_status('delivered').count,
          mail_undelivered: User.email_status('undelivered').count,
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

      # @return [Integer]
      def terms_and_conditions_agreed_count
        User.all.count { |u| u.terms_and_conditions_agreed_at.present? }
      end

      # @note Event.module_start.distinct.count(:user_id)
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
