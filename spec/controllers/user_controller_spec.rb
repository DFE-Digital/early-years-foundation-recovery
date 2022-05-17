require 'rails_helper'

RSpec.describe UserController, type: :controller do
  describe 'update_password' do
    let(:user) { create :user, :registered }

    before do
      sign_in user
    end

    context 'successful' do
      it 'redirects' do
        post :update_password, params: { user: { password: 'NewPassword123', confirm_password: 'NewPassword123', current_password: 'StrongPassword123' } }
        expect(response).to have_http_status(:redirect)
      end

      it 'sets notice' do
        post :update_password, params: { user: { password: 'NewPassword123', confirm_password: 'NewPassword123', current_password: 'StrongPassword123' } }
        expect(flash[:notice]).to match(/Your password has been reset/)
      end
    end

    context 'fails' do
      it 'renders edit' do
        post :update_password, params: { user: { password: 'NewPassword123', confirm_password: 'NewPassword123', current_password: 'wrongpassword' } }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'sets notice' do
        post :update_password, params: { user: { password: 'NewPassword123', confirm_password: 'NewPassword123', current_password: 'wrong' } }
        expect(flash[:notice]).to be_nil
      end
    end
  end
end
