require 'rails_helper'

RSpec.describe Training::NotesController, type: :controller do
  context 'when no user signed in' do
    describe 'GET #show' do
      it 'succeeds' do
        get :show
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  context 'when user signed in' do
    let(:note_params) do
      {
        title: 'my title',
        module_item_id: '7',
        body: 'this is my body',
        training_module: 'alpha',
        name: '1-1-3-1',
      }
    end

    let(:registered_user) { create :user, :registered }

    before { sign_in registered_user }

    describe 'GET #show' do
      it 'redirects to the first live module' do
        first_module = Training::Module.live.first
        expect(first_module).to be_present

        get :show

        expect(response).to redirect_to(
          module_notes_user_path(module_name: first_module.name),
        )
      end
    end

    describe 'POST #create' do
      it 'succeeds' do
        post :create, params: { note: note_params }
        expect(response).to have_http_status(:redirect)
      end
    end

    describe 'POST #update' do
      before { create :note, training_module: 'alpha', name: '1-1-3-1', user: registered_user }

      it 'succeeds' do
        post :update, params: { note: note_params }
        expect(response).to have_http_status(:redirect)
      end
    end
  end
end
