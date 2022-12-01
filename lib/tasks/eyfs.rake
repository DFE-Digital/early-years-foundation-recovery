# rake --tasks eyfs
#
namespace :eyfs do
  desc 'Generate secure bot user'
  task bot: :environment do
    bot_token = ENV.fetch('BOT_TOKEN', SecureRandom.hex(12))

    unless User.find_by(email: "#{bot_token}@example.com")
      User.create!(
        email: "#{bot_token}@example.com",
        password: ENV.fetch('USER_PASSWORD', 'StrongPassword'),
        confirmed_at: Time.zone.now,
        terms_and_conditions_agreed_at: Time.zone.now,
        first_name: 'Bot',
        last_name: 'User',
        setting_type_id: 'childminder_independent',
        local_authority: 'Lewisham',
        role_type: 'childminder',
        registration_complete: true,
        display_whats_new: false,
      )
    end
  end

  desc 'Add page view events for injected module items'
  task plug_content: :environment do
    require 'fill_page_views'
    FillPageViews.new.call
  end

  # @example
  #
  #   $ rake eyfs:whats_new
  #   $ rake 'eyfs:whats_new[completed@example.com,registered@example.com]'
  #   $ rake "eyfs:whats_new[`cat emails.csv`]"
  #
  desc "Enable the post login 'What's new' page"
  task whats_new: :environment do |_task, args|
    number_updated = 0
    total_records = 0

    users =
      if args.present?
        User.where(email: args.to_a)
      else
        User.registered
      end

    users.map do |user|
      user.display_whats_new = true
      user.save!(validate: false)

      number_updated += 1 if user.display_whats_new
      total_records += 1
    end

    puts "Updated #{number_updated} of #{total_records} records"
  end

  desc 'Recalculate module completion time'
  task user_progress: :environment do
    require 'backfill_module_state'
    number_updated = 0
    total_records = 0

    User.registered.map do |user|
      original = user.module_time_to_completion
      BackfillModuleState.new(user: user).call
      updated = user.reload.module_time_to_completion

      puts "User id: #{user.id} - #{updated}"

      number_updated += 1 if original != updated
      total_records += 1
    end

    puts "Updated #{number_updated} of #{total_records} records"
  end

  desc 'Create missing module start/complete events'
  task user_events: :environment do
    require 'backfill_module_events'

    check = proc {
      User.all.count do |user|
        user.events.where(name: 'module_start').count != user.module_time_to_completion.keys.count
      end
    }

    puts check.call

    User.all.each do |user|
      BackfillModuleEvents.new(user: user).call
    end

    puts check.call
  end

  desc 'Confirm events align with user state'
  task confirm_events: :environment do
    require 'check_module_events'
    valid = CheckModuleEvents.new.call
    puts valid ? 'Start/Complete events are present' : 'Oops'
  end
end
