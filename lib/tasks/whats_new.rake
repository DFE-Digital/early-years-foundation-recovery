namespace :db do
  desc 'Set all users display_whats_new to true'
  task display_whats_new: :environment do
    number_updated = 0
    total_records = 0

    User.all.map do |user|
      user.display_whats_new = true
      user.save

      number_updated += 1 if user.display_whats_new == true
      total_records += 1
    end
    p "Updated #{number_updated} of #{total_records} records"
  end
end
