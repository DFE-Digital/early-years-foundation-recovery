require 'rails_helper'

RSpec.describe DataAnalysis::UserCountByRoleAndExperience do
  let(:headers) do
    %w[
      Role
      Experience
      Count
    ]
  end

  let(:rows) do
    [
      {
        role_type: 'Childminder',
        experience: '0-2',
        count: 2,
      },
      {
        role_type: 'Childminder',
        experience: '6-9',
        count: 1,
      },
    ]
  end

  before do
    create :user, :agency_childminder
    create :user, :independent_childminder
    create :user, :independent_childminder
  end

  it_behaves_like 'a data export model'
end
