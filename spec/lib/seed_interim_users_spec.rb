require 'rails_helper'
require 'seed_interim_users'

RSpec.describe SeedInterimUsers do
  xdescribe 'seed_interim_users.rake' do
    # skip unless ENV['INTERIM']

    it 'adds valid user to database and views all module 1 pages' do
      described_class.new.seed_interim_users
      user = User.find_by(email: 'ben.miller@test.com')
      expect(user).to be_present
      module_items = ModuleItem.where(training_module: 'child-development-and-the-eyfs')
      module_completed = module_items.all? do |item|
        user.events.where_properties(training_module_id: 'child-development-and-the-eyfs', id: item.name)
      end
      expect(module_completed).to be true
    end

    it 'if email is invalid, does not add user' do
      described_class.new.seed_interim_users
      expect(User.where(email: 'ttttolatunjihtest.com')).not_to exist
      expect { described_class.new.seed_interim_users }.to output(a_string_including('Skipping user: ttttolatunjihtest.com creation as it is invalid.')).to_stdout
    end

    it 'if email already exists, does not add user' do
      create(:user, :confirmed, email: 'ben.miller@test.com')
      expect(User.find_by(email: 'ben.miller@test.com')).to be_present
      expect { described_class.new.seed_interim_users }.to output(a_string_including('Skipping user: ben.miller@test.com creation as it already exists.')).to_stdout
    end
  end
end
