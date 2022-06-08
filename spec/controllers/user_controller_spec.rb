require 'rails_helper'

RSpec.describe UserController, type: :controller do
  describe '#update_password' do
    let(:user) { create :user, :registered }
    let(:params) { {} }

    before do
      sign_in user
      post :update_password, params: { user: params }
    end

    context 'when successful' do
      let(:params) do
        {
          password: 'NewPassword123',
          confirm_password: 'NewPassword123',
          current_password: 'StrongPassword123',
        }
      end

      it 'redirects' do
        expect(response).to have_http_status(:redirect)
      end

      it 'renders a flash notice' do
        expect(flash[:notice]).to match(/Your password has been reset/)
      end
    end

    context 'when current password is wrong' do
      let(:params) do
        {
          password: 'NewPassword123',
          confirm_password: 'NewPassword123',
          current_password: 'wrongpassword',
        }
      end

      it 'renders edit' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'does not render a flash notice' do
        expect(flash[:notice]).to be_nil
      end
    end

    context 'when new password is blank' do
      let(:params) do
        {
          password: '',
          confirm_password: '',
          current_password: 'StrongPassword123',
        }
      end

      it 'renders edit' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'does not render a flash notice' do
        expect(flash[:notice]).to be_nil
      end
    end
  end
end
