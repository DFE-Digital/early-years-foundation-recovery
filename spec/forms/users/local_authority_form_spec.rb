require 'rails_helper'

RSpec.describe Users::LocalAuthorityForm do
  let(:user) { create(:user) }
  let(:local_authority_form) { described_class.new(user: user) }

  specify 'updates local authority' do
    local_authority_form.local_authority = 'local authority'
    local_authority_form.save
    expect(user.local_authority).to eq('local authority')
  end

  specify 'page heading, body and button translated correctly' do
    expect(local_authority_form.heading).to eq('What local authority area do you work in?')
    expect(local_authority_form.body).to eq(/county council, district council or London borough/)
    expect(local_authority_form.button).to eq('Continue')
  end
end
