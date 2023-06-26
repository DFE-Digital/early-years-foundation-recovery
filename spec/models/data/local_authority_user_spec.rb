require 'rails_helper'

RSpec.describe Data::LocalAuthorityUser do
  let(:headers) do
    ['Local Authority', 'Users']
  end

  let(:rows) do
    [
      {
        local_authority: 'LA3',
        users: 1
      },
      {
        local_authority: 'LA1',
        users: 2
      }
    ]
  end

  before do
    create(:user, :registered, local_authority: 'LA1', created_at: Time.zone.now)
    create(:user, :registered, local_authority: 'LA1', created_at: Time.zone.now)
    create(:user, :registered, local_authority: 'LA3', created_at: Time.zone.now)
  end

  it_behaves_like('a data export model')
end
