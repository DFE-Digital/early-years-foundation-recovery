require 'rails_helper'

RSpec.describe Data::UserOverview do
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
        registration_complete: 5,
        registration_incomplete: 1,
        reregistered: 0,
        registered_since_private_beta: 6,
        private_beta_only_registration_incomplete: 0,
        private_beta_only_registration_complete: 0,
        registration_events: 0,
        private_beta_registration_events: 0,
        public_beta_registration_events: 0,
        total: 6,
        locked_out: 0,
        confirmed: 6,
        unconfirmed: 0,
        user_defined_roles: 2,
        started_learning: 4,
        not_started_learning: 2,
        with_notes: 3,
        with_notes_percentage: 0.5,
        without_notes: 3,
        without_notes_percentage: 0.5,
        complete_registration_mail_recipients: 1,
        start_training_mail_recipients: 1,
        continue_training_mail_recipients: 0,
        new_module_mail_recipients: 2,
      },
    ]
  end

  let(:user_1) do
    create :user, :registered, module_time_to_completion: { alpha: 1, bravo: 1, charlie: 0 }
  end

  let(:user_2) do
    create :user, :registered, module_time_to_completion: { alpha: 2, bravo: 3, charlie: 1 }
  end

  let(:user_3) do
    create :user, :registered, module_time_to_completion: { alpha: 2, bravo: 0, charlie: 1 }
  end

  let(:release_1) { create(:release) }

  before do
    create(:module_release, release_id: release_1.id, module_position: 1, name: 'alpha')
    create(:module_release, release_id: release_1.id, module_position: 2, name: 'bravo')
    create(:module_release, release_id: release_1.id, module_position: 3, name: 'charlie')
    create(:note, user: user_1)
    create(:note, user: user_2)
    create(:note, user: user_3)
    create(:user, :registered, module_time_to_completion: { alpha: 2, charlie: 1, bravo: 3 })
    create(:user, :confirmed, confirmed_at: 4.weeks.ago)
    create(:user, :registered, confirmed_at: 4.weeks.ago)
  end

  it_behaves_like 'a data export model'
end
