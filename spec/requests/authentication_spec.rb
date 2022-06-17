require 'rails_helper'

RSpec.describe 'Authentication', type: :request do
  describe 'viewing authenticate_user! controller action' do
    let(:action_path) { edit_extra_registration_path(ExtraRegistrationsController::STEPS.first) }

    context 'with User not signed in' do
      it 'redirects to sign in page' do
        get action_path
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'displays message to sign in' do
        get action_path
        follow_redirect!
        expect(response.body).to include('You need to sign in')
      end
    end

    context 'with unconfirmed user' do
      before { sign_in create(:user) }

      it 'redirects to sign in page' do
        get action_path
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'displays message that confirmation link email sent' do
        get action_path
        follow_redirect!
        expect(response.body).to include('You have to confirm your email address')
      end
    end

    context 'with partially registered User' do
      before { sign_in create(:user, :confirmed) }

      it 'renders page' do
        get action_path
        expect(response).to have_http_status(:success)
      end
    end

    context 'with registered User' do
      before { sign_in create(:user, :registered) }

      it 'renders page' do
        get action_path
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'viewing :authenticate_registered_user! controller action' do
    let(:action_path) { my_learning_path }

    context 'with User not signed in' do
      it 'redirects to sign in page' do
        get action_path
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'displays message to sign in' do
        get action_path
        follow_redirect!
        expect(response.body).to include('You need to sign in')
      end
    end

    context 'with unconfirmed user' do
      before { sign_in create(:user) }

      it 'redirects to sign in page' do
        get action_path
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'displays message that confirmation link email sent' do
        get action_path
        follow_redirect!
        expect(response.body).to include('You have to confirm your email address')
      end
    end

    context 'with partially registered User' do
      before { sign_in create(:user, :confirmed) }

      it 'redirects to extra registration' do
        get action_path
        expect(response).to redirect_to(extra_registrations_path)
      end

      it 'displays message to complete registration' do
        get action_path
        follow_redirect!
        follow_redirect!
        expect(response.body).to include('Please complete registration')
      end
    end

    context 'with registered User' do
      before { sign_in create(:user, :registered) }

      it 'renders page' do
        get action_path
        expect(response).to have_http_status(:success)
      end
    end
  end
end
