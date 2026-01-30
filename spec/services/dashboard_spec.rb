require 'rails_helper'

RSpec.describe Dashboard do
  subject(:service) { described_class.new(path: path) }

  let(:path) { Rails.root.join('tmp/dashboard-test') }

  before do
    FileUtils.rm_rf(path, secure: true)
    create(:user, :registered, id: 123, local_authority: 'Watford Borough Council')

    # Stub GCS upload for the upload test
    allow(Google::Cloud::Storage).to receive(:new).and_raise(StandardError, 'Authorization failed')

    service.call
  end

  after do
    FileUtils.rm_rf(path, secure: true)
  end

  describe '#call' do
    let(:data_files) { Dir.glob path.join('*/*/*.csv') }

    describe 'exported files' do
      specify { expect(data_files.count).to eq described_class::DATA_SOURCES.size }
    end

    it 'exports data in CSV format' do
      user_file = data_files.find { |f| f.match?('/users.csv') }
      user_data = File.read(user_file).split("\n").last
      expect(user_data).to include '123,Watford Borough Council,'
    end

    it 'only uploads on demand' do
      expect { service.call(upload: true) }.to raise_error(StandardError, /Authorization failed/)
    end
  end
end
