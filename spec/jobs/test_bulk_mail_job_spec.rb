require 'rails_helper'

RSpec.describe TestBulkMailJob do
  let!(:included) do
    valid = create_list :user, 3, :team_member
    invalid = create :user, :registered, email: 'invalid@education.gov.uk.' # full stop at end
    valid << invalid
  end

  let!(:excluded) do
    create_list :user, 2, :registered
  end

  it_behaves_like 'an email prompt'

  it 'uses personalisation' do
    body = NotifyMailer.send(described_class.template, included.first).message.body.to_s
    expect(body).to include "template #{described_class.template_id} and personalisation: "
  end
end
