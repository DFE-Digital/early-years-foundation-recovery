require "SeedInterimUsers"

namespace :db do
  namespace :seed do
    desc 'Seed interim users data from yaml into database'
    task interim_users: :environment do
      SeedInterimUsers.new.seed_interim_users
    end
  end
end
