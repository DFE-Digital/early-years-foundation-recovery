require 'rails_helper'

RSpec.describe Data::UserOverview do
  let!(:user_1) { create(:user, :registered, module_time_to_completion: { alpha: 1, bravo: 1, charlie: 0 }) }
  let!(:user_2) { create(:user, :registered, module_time_to_completion: { alpha: 2, bravo: 3, charlie: 1 }) }
  let!(:user_3) { create(:user, :registered, module_time_to_completion: { alpha: 2, bravo: 0, charlie: 1 }) }

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
      'Following Linear Sequence',
      'With Notes',
      'With Notes Percentage',
      'Without Notes',
      'Without Notes Percentage',
    ]
  end
  let(:rows) do
    [
      {
        registration_complete: 4,
        registration_incomplete: 0,
        reregistered: 0,
        registered_since_private_beta: 4,
        private_beta_only_registration_incomplete: 0,
        private_beta_only_registration_complete: 0,
        registration_events: 0,
        private_beta_registration_events: 0,
        public_beta_registration_events: 0,
        total: 4,
        locked_out: 0,
        confirmed: 4,
        unconfirmed: 0,
        user_defined_roles: 1,
        started_learning: 4,
        not_started_learning: 0,
        following_linear_sequence: 2,
        with_notes: 3,
        with_notes_percentage: 0.75,
        without_notes: 1,
        without_notes_percentage: 0.25,
      },
    ]
  end

  before do
    create(:note, user: user_1)
    create(:note, user: user_2)
    create(:note, user: user_3)
    create(:user, :registered, module_time_to_completion: { alpha: 2, charlie: 1, bravo: 3 })
  end

  it_behaves_like('a data export model')
end
