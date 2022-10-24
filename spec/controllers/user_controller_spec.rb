require 'rails_helper'

RSpec.describe UserController, type: :controller do
  let(:user) { create :user, :registered }
  let(:params) { {} }

  describe '#update_email' do
    before do
      sign_in user
      post :update_email, params: {user: params }
    end

    context 'when successful' do
      let(:params) do
        {
          email: 'user@example.com'
        }
      end
      
      it 'redirects' do 
        expect(response).to have_http_status(:redirect)
      end

      it 'renders a flash notice' do 
        expect(flash[:notice]).to match(/We have sent an email to your new email address with a link to click to confirm the change.\n\nIf you have not received the email after a few minutes, please check your spam folder.\n/)
      end
    end

    context 'when email is wrong' do
      let(:params) do
        {
          email: 'invalidemail'
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

  describe '#update_password' do
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
        expect(flash[:notice]).to match(/Your new password has been saved./)
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
