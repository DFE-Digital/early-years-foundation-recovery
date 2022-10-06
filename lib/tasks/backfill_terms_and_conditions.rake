namespace :db do
  desc 'Backfill terms_and_conditions_agreed_at'
  task backfill_terms_and_conditions: :environment do
    number_updated = 0
    total_records = 0

    User.all.map do |user|
      original = user.terms_and_conditions_agreed_at
      if original.nil?
        user.terms_and_conditions_agreed_at = user.created_at
        user.save!(validate: false)

        if original != user.reload.terms_and_conditions_agreed_at
          number_updated += 1
          p "User id: #{user.id} updated"
        end
      end
      total_records += 1
    end
    p "Updated #{number_updated} of #{total_records} records"
  end
end
