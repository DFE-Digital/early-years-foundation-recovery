require 'seed_interim_users'

namespace :db do
  namespace :seed do
    desc 'Seed interim users data from yaml into database'
    task interim_users: :environment do
      seed_file = Rails.root.join('db/seeds/interim_data.yml')
      users = YAML.load_file(seed_file)
      SeedInterimUsers.seed_interim_users(users)
    end
  end
end
