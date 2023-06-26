module Data
  class UserOverview
    include ToCsv

    def self.column_names
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
      ]
    end

    def self.dashboard
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
      }]
    end

    # @return [Float]
    def self.with_notes_percentage
      with_notes_count / User.count
    end

    # @return [Integer]
    def self.with_notes_count
      User.not_closed.with_notes.count
    end

    # @return [Integer]
    def self.without_notes_count
      User.not_closed.without_notes.count
    end

    def self.started_learning
      User.all.map { |u| u.module_time_to_completion.keys }.count(&:present?)
    end

    def self.not_started_learning
      User.all.map { |u| u.module_time_to_completion.keys }.count(&:empty?)
    end
  end
end