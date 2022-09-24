require 'rails_helper'

RSpec.describe AnalyticsBuild do
  let(:users_all) { User.all }

  let(:users_results) { described_class.new(bucket_name: 'test_bucket', folder_path: 'test_bucket/user', result_set: users_all, file_name: 'users', json_property_name: 'module_time_to_completion') }

  describe 'build analytics data' do
    before do
      create :user, :registered
      create :user, :registered
      create :user, :registered
    end

    it 'set bucket_name' do
      expect(users_results.bucket_name).to eq('test_bucket')
    end

    it 'set folder_path' do
      expect(users_results.folder_path).to eq('test_bucket/user')
    end

    it 'set file_name' do
      expect(users_results.file_name).to eq('users')
    end

    it 'set json_property_name' do
      expect(users_results.json_property_name).to eq('module_time_to_completion')
    end
  end

  describe '#serialize' do
    context 'convert active record object into array'
    it 'before serialize' do
      expect(users_results.result_set.class.to_s).to eq('User::ActiveRecord_Relation')
    end

    it 'after serialize' do
      expect(users_results.serialize(users_results.result_set).class.to_s).to eq('Array')
    end
  end
end
