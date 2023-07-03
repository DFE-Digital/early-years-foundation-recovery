require 'update_user'

namespace :eyfs do
  namespace :email_preferences do
    include UpdateUser
    desc 'update email preferences for each email address'
    task :update, [:email] => :environment do |_task, args|
        email_preferences_unsubscribe(args.to_a)
    end
  end
end
