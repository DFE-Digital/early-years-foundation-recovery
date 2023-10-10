require 'rails_helper'

RSpec.describe DataAnalysis::UserOverview do
  include_context 'with progress'
  let(:headers) do
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

  let(:rows) do
    [
      {
        registration_complete: 4,
        registration_incomplete: 1,
        reregistered: 0,
        registered_since_private_beta: 5,
        private_beta_only_registration_incomplete: 0,
        private_beta_only_registration_complete: 0,
        registration_events: 0,
        private_beta_registration_events: 0,
        public_beta_registration_events: 0,
        total: 5,
        locked_out: 0,
        confirmed: 5,
        unconfirmed: 0,
        user_defined_roles: 2,
        started_learning: 3,
        not_started_learning: 2,
        with_notes: 2,
        with_notes_percentage: 0.4,
        without_notes: 3,
        without_notes_percentage: 0.6,
        complete_registration_mail_recipients: 1,
        start_training_mail_recipients: 1,
        continue_training_mail_recipients: 0,
        new_module_mail_recipients: 1,
      },
    ]
  end

  let(:user_1) do
    create :user, :registered, module_time_to_completion: { alpha: 1, bravo: 1, charlie: 0 }
  end

  let(:user_2) do
    create :user, :registered, module_time_to_completion: { alpha: 2, bravo: 0, charlie: 1 }
  end

  let(:release_1) { create(:release) }

  before do
    # create records for the previously released modules completed by the `new_module_mail_recipients`
    create(:module_release, release_id: release_1.id, module_position: 1, name: 'alpha')
    create(:module_release, release_id: release_1.id, module_position: 2, name: 'bravo')
    create(:module_release, release_id: release_1.id, module_position: 3, name: 'charlie')

    # create notes for the `with_notes` and `without_notes` users
    create(:note, user: user_1)
    create(:note, user: user_2)

    # A user who confirmed their email 4 weeks ago will receive the complete registration mail
    create(:user, :confirmed, confirmed_at: 4.weeks.ago)
    # A registered user who will receive the start training mail
    create(:user, :registered, confirmed_at: 4.weeks.ago)

    # This will complete the alpha, bravo and charlie modules for `user`
    complete_module(alpha, 1.minute)
    complete_module(bravo, 1.minute)
    complete_module(charlie, 1.minute)
  end

  it_behaves_like 'a data export model'
end
