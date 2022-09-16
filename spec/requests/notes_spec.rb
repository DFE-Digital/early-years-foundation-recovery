require 'rails_helper'

RSpec.describe 'Learning log', type: :request do
  let(:registered_user) { create :user, :registered }
  let(:note_params) do
    {
      title: 'my title',
      module_item_id: '7',
      body: 'this is my body',
      training_module: 'alpha',
      name: '1-1-3-1',
    }
  end

  before do
    sign_in registered_user
  end

  describe 'GET /my-account/learning-log' do
    specify { expect('/my-account/learning-log').to be_successful }

    it 'indicates no notes when there are none' do
      get user_notes_path
      expect(response.body).to include('You have not made any notes for this module.')
    end

    it 'lists notes' do
      create :note, user: registered_user, body: 'My very special note'
      get user_notes_path
      expect(response.body).to include('Your learning log')
      expect(response.body).to include('My very special note')
    end
  end

  describe 'POST /my-account/learning-log' do
    it 'succeeds' do
      expect { post user_notes_path, params: { note: note_params } }.to change(Note, :count).by(1)
    end
  end

  describe 'PATCH /my-account/learning-log' do
    before { create :note, training_module: 'alpha', name: '1-1-3-1', user: registered_user }

    it 'succeeds' do
      expect { patch user_notes_path, params: { note: note_params } }.not_to change(Note, :count)
    end
  end
end
