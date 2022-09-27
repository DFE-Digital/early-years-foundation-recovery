namespace :db do
  namespace :seed do
    desc 'Seed interim users data from yaml into database'
    task interim_users: :environment do
      require 'seed_interim_users'
      SeedInterimUsers.new.seed_interim_users
    end
  end
end
