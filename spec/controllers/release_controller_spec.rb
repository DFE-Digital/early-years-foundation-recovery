require 'rails_helper'

RSpec.describe ReleaseController, type: :controller do
  let(:payload_data) do
    {
      'sys' => {
        'id' => 'module_123',
        'completedAt' => Time.zone.now,
        'updatedAt' => Time.zone.now,
      },
    }
  end

  let(:valid_release_params) { payload_data }

  before do
    # bypass authentication for tests
    # This disable is necessary because the controller inherits from WebhookController which requires authentication
    # rubocop:disable RSpec/ReceiveMessages
    allow(controller).to receive(:authenticate_webhook!).and_return(true)

    # stub the Resource class to avoid loading it from the database
    stub_const('Resource', Class.new do
      def self.reset_cache_key!; end
    end)
    allow(Resource).to receive(:reset_cache_key!)
    allow(Page).to receive(:reset_cache_key!)

    # stub background jobs
    allow(NewModuleMailJob).to receive(:enqueue)
    allow(ContentCheckJob).to receive(:enqueue)

    # stub payload method
    allow(controller).to receive(:payload).and_return(payload_data)
    # rubocop:enable RSpec/ReceiveMessages

    # spy on Training::Module.cache
    allow(Training::Module.cache).to receive(:clear)
  end

  describe 'POST #new' do
    it 'creates a new Release record' do
      expect {
        post :new, params: { release: valid_release_params }
      }.to change(Release, :count).by(1)
    end

    it 'clears the module cache' do
      post :new, params: { release: valid_release_params }
      expect(Training::Module.cache).to have_received(:clear)
    end

    it 'enqueues NewModuleMailJob' do
      post :new, params: { release: valid_release_params }
      release = Release.last
      expect(NewModuleMailJob).to have_received(:enqueue).with(release.id)
    end

    it 'succeeds' do
      post :new, params: { release: valid_release_params }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #update' do
    it 'creates a new Release record' do
      expect {
        post :update, params: { release: valid_release_params.merge(id: 1) }
      }.to change(Release, :count).by(1)
    end

    it 'clears the module cache' do
      post :update, params: { release: valid_release_params.merge(id: 1) }
      expect(Training::Module.cache).to have_received(:clear)
    end

    it 'enqueues ContentCheckJob' do
      post :update, params: { release: valid_release_params.merge(id: 1) }
      expect(ContentCheckJob).to have_received(:enqueue)
    end

    it 'succeeds' do
      post :update, params: { release: valid_release_params.merge(id: 1) }
      expect(response).to have_http_status(:success)
    end
  end
end
