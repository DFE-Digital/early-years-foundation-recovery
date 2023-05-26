# rake --tasks eyfs
#
namespace :eyfs do
  # curl -H "BOT: #{ENV['BOT_TOKEN']}" http://localhost:3000/audit
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

  namespace :jobs do
    # NB: Not yet CMS compatible
    desc 'Add page view events for injected module items'
    task plug_content: :environment do
      FillPageViewsJob.enqueue
    end

    # Queueing a dashboard job via Rake inverts the default and will not
    #   upload files to Looker Studio unless explicitly requested.
    #
    # @example
    #
    #   $ rake 'eyfs:jobs:dashboard[upload]'
    #   $ rake eyfs:jobs:dashboard
    #
    desc 'Update dashboard data sources (optional upload)'
    task :dashboard, [:upload] => :environment do |_task, upload: false|
      DashboardJob.enqueue(upload: upload.present?)
    end
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
        User.registration_complete
      end

    users.map do |user|
      user.display_whats_new = true
      user.save!(validate: false)

      number_updated += 1 if user.display_whats_new
      total_records += 1
    end

    puts "Updated #{number_updated} of #{total_records} records"
  end

  desc 'Fake completed course'
  task state: :environment do |_task, _args|
    require 'content_seed'

    user = User.find_by(email: 'completed@example.com')

    Training::Module.ordered.reject(&:draft?).each do |mod|
      ContentSeed.new(mod: mod, user: user).call
    end
  end
end
