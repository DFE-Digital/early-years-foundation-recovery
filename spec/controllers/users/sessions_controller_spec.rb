require 'rails_helper'

RSpec.describe Users::SessionsController, type: :controller do
  before do
    request.env['devise.mapping'] = Devise.mappings[:user]
    post :create, params: { user: { email: user.email, password: user.password } }
  end

  let(:user) { create :user, :registered }

  context 'when registration is complete' do
    it 'continues to their training overview' do
      expect(response).to redirect_to '/my-modules'
    end
  end

  context 'when new feature alert is enabled' do
    let(:user) do
      create :user, :registered, display_whats_new: true
    end

    it 'redirects to /whats-new' do
      expect(response).to redirect_to '/whats-new'
    end
  end

  context 'when email preferences are not defined' do
    let(:user) do
      create :user, :registered, training_emails: nil
    end

    it 'redirects to email preferences form' do
      expect(response).to redirect_to '/email-preferences'
    end
  end

  context 'when registered during private beta' do
    let(:user) do
      create :user, :registered, registration_complete: false, private_beta_registration_complete: true
    end

    it 'redirects to new registration' do
      expect(response).to redirect_to '/new-registration'
    end
  end
end
