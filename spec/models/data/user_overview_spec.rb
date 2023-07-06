require 'rails_helper'

RSpec.describe Data::UserOverview do
  let!(:user_1) { create(:user, :registered) }
  let!(:user_2) { create(:user, :registered) }

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
    ]
  end
  let(:rows) do
    [
      {
        registration_complete: 2,
        registration_incomplete: 0,
        reregistered: 0,
        registered_since_private_beta: 2,
        private_beta_only_registration_incomplete: 0,
        private_beta_only_registration_complete: 0,
        registration_events: 0,
        private_beta_registration_events: 0,
        public_beta_registration_events: 0,
        total: 2,
        locked_out: 0,
        confirmed: 2,
        unconfirmed: 0,
        user_defined_roles: 1,
        started_learning: 0,
        not_started_learning: 2,
        with_notes: 2,
        with_notes_percentage: 1,
        without_notes: 0,
        without_notes_percentage: 0,
      },
    ]
  end

  before do
    create(:note, user: user_1)
    create(:note, user: user_2)
  end

  it_behaves_like('a data export model')
end
