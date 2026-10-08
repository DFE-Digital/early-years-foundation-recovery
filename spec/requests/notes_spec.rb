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
    it 'redirects to the first live module when no modules have been started' do
      first_module = Training::Module.live.first
      expect(first_module).to be_present

      get user_notes_path

      expect(response).to redirect_to(
        module_notes_user_path(module_name: first_module.name),
      )
    end

    context 'when no live modules are available' do
      before do
        allow(Training::Module).to receive(:live).and_return([])
      end

      it 'shows an informative empty state' do
        get user_notes_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include(
          'There are no modules available at the moment.',
        )
      end
    end
  end

  describe 'GET /my-account/learning-log/:module_name' do
    let(:selected_module) { Training::Module.live.first }

    it 'shows an empty state when there are no notes' do
      expect(selected_module).to be_present
      get module_notes_user_path(module_name: selected_module.name)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(
        'You have not made any notes for this module.',
      )
    end

    it 'shows an empty state when notes contain only whitespace' do
      expect(selected_module).to be_present
      create :note,
             user: registered_user,
             training_module: selected_module.name,
             body: " \n \n"
      get module_notes_user_path(module_name: selected_module.name)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(
        'You have not made any notes for this module.',
      )
    end

    it 'shows the current user’s notes for the selected module' do
      expect(selected_module).to be_present
      create :note,
             user: registered_user,
             training_module: selected_module.name,
             body: 'My reflection on supporting children'

      get module_notes_user_path(module_name: selected_module.name)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(
        'My reflection on supporting children',
      )
      expect(response.body).not_to include(
        'You have not made any notes for this module.',
      )
    end

    it 'does not show another user’s notes' do
      expect(selected_module).to be_present

      other_user = create :user, :registered

      create :note,
             user: other_user,
             training_module: selected_module.name,
             body: 'Another learner’s private reflection'

      get module_notes_user_path(module_name: selected_module.name)

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include(
        'Another learner’s private reflection',
      )
      expect(response.body).to include(
        'You have not made any notes for this module.',
      )
    end

    it 'does not show notes from another module' do
      expect(selected_module).to be_present

      other_module = Training::Module.live.find do |mod|
        mod.name != selected_module.name
      end
      expect(other_module).to be_present

      create :note,
             user: registered_user,
             training_module: other_module.name,
             body: 'My reflection from a different module'

      get module_notes_user_path(module_name: selected_module.name)

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include(
        'My reflection from a different module',
      )
      expect(response.body).to include(
        'You have not made any notes for this module.',
      )
    end

    it 'rejects an unknown module' do
      expect {
        get module_notes_user_path(module_name: 'nonexistent-module')
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'rejects a module that is not live' do
      expect(selected_module).to be_present
      module_name = selected_module.name

      allow(Training::Module).to receive(:live).and_return([])

      expect {
        get module_notes_user_path(module_name: module_name)
      }.to raise_error(ActiveRecord::RecordNotFound)
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
