require 'module_completion_existing_users'

namespace :db do
  desc 'Calculate module completion time for existing users'
  task calculate_completion_time: :environment do
    number_updated = 0
    total_records = 0
    User.update_all(module_time_to_completion: {})
    
    User.all.map do |user|
      original = user.module_time_to_completion
      BackfillModuleState.new(user: user).call
      updated = user.reload.module_time_to_completion

      p "User id: #{user.id} - #{updated}"
      
      number_updated += 1 if original != updated
      total_records += 1
    end
    p "Updated #{number_updated} of #{total_records} records"
  end
end