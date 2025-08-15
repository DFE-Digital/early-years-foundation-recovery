require 'rails_helper'

RSpec.describe ReleaseController, type: :controller do
  let(:payload_data) do
    {
      'sys' => {
        'id' => 'module_123',
        'completedAt' => Time.zone.now.iso8601,
        'updatedAt' => Time.zone.now.iso8601,
      },
    }
  end

  let(:valid_release_params) { payload_data }

  # disable RSpec/VerifiedDoubles Since Rails.logger is a real object that can’t replace with a verifying double
  # rubocop:disable RSpec/VerifiedDoubles
  let(:logger_spy) { spy('logger') }
  # rubocop:enable RSpec/VerifiedDoubles

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

    # spy on logger
    allow(Rails).to receive(:logger).and_return(logger_spy)

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

    it 'logs messages correctly' do
      post :new, params: { release: valid_release_params }
      release = Release.last

      expect(logger_spy).to have_received(:info).with('[ReleaseController#new] Clearing module cache before creating new release')
      expect(logger_spy).to have_received(:info).with(
        "[ReleaseController#new]\n      Created Release with ID: #{release.id}, sys_id: #{payload_data.dig('sys', 'id')}",
      )
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

    it 'logs messages correctly' do
      post :update, params: { release: valid_release_params.merge(id: 1) }
      release = Release.last

      expect(logger_spy).to have_received(:info).with('[ReleaseController#update] Clearing module cache before updating release')
      expect(logger_spy).to have_received(:info).with(
        "[ReleaseController#update]\n      Created Release with ID: #{release.id}, sys_id: #{payload_data.dig('sys', 'id')}",
      )
    end
  end
end
