namespace :db do
  desc 'generate secure bot user'
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
      )
    end
  end
end
