require 'rails_helper'

RSpec.describe DataAnalysis::LocalAuthorityUser do
  let(:headers) do
    [
      'Local Authority',
      'Users',
    ]
  end

  let(:rows) do
    [
      {
        local_authority: 'LA1',
        users: 2,
      },
      {
        local_authority: 'LA3',
        users: 1,
      },
    ]
  end

  before do
    # Incomplete registration
    create :user, :named, local_authority: 'LA3'

    # Registered user
    create :user, :registered, local_authority: 'LA1'
    create :user, :registered, local_authority: 'LA1'
    create :user, :registered, local_authority: 'LA3'
  end

  it_behaves_like 'a data export model'
end
