require 'rails_helper'
require 'SeedInterimUsers'
require 'rake'

RSpec.describe SeedInterimUsers do
  Rails.application.load_tasks

  let(:seed_file) do
    Rails.root.join('db/seeds/interim_test_data.yml')
  end
  let(:users) do
    YAML.load_file(seed_file)
  end

  describe 'load_interim_data.rake' do
    it 'adds valid user to database and views all module 1 pages' do
      SeedInterimUsers.seed_interim_users(users)
      user = User.find_by(email: 'ben.miller@test.com')
      expect(user).to be_present
      module_items = ModuleItem.where(training_module: 'child-development-and-the-eyfs')
      module_completed = module_items.all? do |item|
        user.events.where_properties(training_module_id: 'child-development-and-the-eyfs', id: item.name)
      end
      expect(module_completed).to be true
    end

    it 'if email is invalid, does not add user' do
      SeedInterimUsers.seed_interim_users(users)
      expect(User.where(email: 'ttttolatunjihtest.com')).not_to exist
      expect { SeedInterimUsers.seed_interim_users(users) }.to output(a_string_including('Skipping user: ttttolatunjihtest.com creation as it is invalid.')).to_stdout
    end

    it 'if email already exists, does not add user' do
      Rake::Task['db:seed'].invoke
      expect(User.where(email: 'ben.miller@test.com')).to exist
      expect { SeedInterimUsers.seed_interim_users(users) }.to output(a_string_including('Skipping user: ben.miller@test.com creation as it already exists.')).to_stdout
    end
  end
end
