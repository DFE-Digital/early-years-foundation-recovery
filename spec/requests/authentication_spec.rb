require 'rails_helper'

RSpec.describe 'Authentication', type: :request do
  describe '#authenticate_user!' do
    describe 'a guest' do
      before do
        get edit_registration_terms_and_conditions_path
      end

      it { expect(response).to redirect_to new_user_session_path }

      it 'must authenticate' do
        follow_redirect!
        expect(response.body).to include 'You need to sign in'
      end
    end

    describe 'a user' do
      before do
        sign_in user
        get edit_registration_terms_and_conditions_path
      end

      context 'when partially registered' do
        let(:user) { create :user, :confirmed }

        it { expect(response).to have_http_status :success }
      end

      context 'when registered' do
        let(:user) { create :user, :registered }

        it { expect(response).to have_http_status :success }
      end
    end
  end

  describe '#authenticate_registered_user!' do
    describe 'a guest' do
      before do
        get my_modules_path
      end

      it { expect(response).to redirect_to new_user_session_path }

      it 'must authenticate' do
        follow_redirect!
        expect(response.body).to include 'You need to sign in'
      end
    end

    describe 'a user' do
      before do
        sign_in user
        get my_modules_path
      end

      context 'when partially registered' do
        let(:user) { create :user, :confirmed }

        it do
          expect(response).to redirect_to edit_registration_setting_type_path
        end

        it 'registration must be completed' do
          follow_redirect!
          expect(response.body).to include 'You must finish your profile registration before you can use this service.'
        end
      end

      context 'when registered' do
        let(:user) { create :user, :registered }

        it { expect(response).to have_http_status :success }
      end
    end
  end
end
