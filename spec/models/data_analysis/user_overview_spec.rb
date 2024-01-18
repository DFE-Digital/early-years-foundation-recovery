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
      'GovOne',
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
      'Closed',
      'Terms and Conditions Agreed',
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
        gov_one: 1,
        user_defined_roles: 2,
        started_learning: 3,
        not_started_learning: 3,
        with_notes: 2,
        with_notes_percentage: 0.33,
        without_notes: 4,
        without_notes_percentage: 0.67,
        complete_registration_mail_recipients: 1,
        start_training_mail_recipients: 1,
        continue_training_mail_recipients: 0,
        new_module_mail_recipients: 6,
        closed: 0,
        terms_and_conditions_agreed: 6,
      },
    ]
  end

  let(:user) do
    create :user, :registered
  end

  let(:user_2) do
    create :user, :registered,
           module_time_to_completion: { alpha: 1, bravo: 1, charlie: 0 }
  end

  let(:user_3) do
    create :user, :registered,
           module_time_to_completion: { alpha: 2, bravo: 0, charlie: 1 }
  end

  let(:release) { create(:release) }

  before do
    create :module_release, release_id: release.id, module_position: 1, name: 'alpha'
    create :module_release, release_id: release.id, module_position: 2, name: 'bravo'
    create :module_release, release_id: release.id, module_position: 3, name: 'charlie'

    # user#1
    complete_module alpha, 1.minute
    complete_module bravo, 1.minute
    complete_module charlie, 1.minute

    # user#2 user#3 with notes
    create :note, user: user_2
    create :note, user: user_3

    # user#4 complete registration notification
    create :user, :confirmed, confirmed_at: 4.weeks.ago
    # user#5 start training notification
    create :user, :registered, confirmed_at: 4.weeks.ago
    # user#6
    create :gov_one_user
  end

  it_behaves_like 'a data export model'
end
