require 'rails_helper'

RSpec.describe Dashboard do
  subject(:service) { described_class.new(path: path) }

  let(:path) { Rails.root.join('tmp/dashboard-test') }

  before do
    create(:user, :registered, id: 123, local_authority: 'Watford Borough Council')
    service.call
  end

  after do
    FileUtils.rm_rf(path, verbose: true, secure: true)
  end

  describe '#call' do
    let(:data_files) { Dir.glob path.join('*/*/*.csv') }

    it 'exports 7 database tables' do
      expect(data_files.count).to be 20
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
