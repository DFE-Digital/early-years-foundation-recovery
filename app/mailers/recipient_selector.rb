module RecipientSelector
    def complete_registration_recipients
        unregistered = User.training_email_recipients.registration_incomplete
        puts "module thinks this is 4 weeks ago: #{4.weeks.ago}"
        puts "module thinks this is 1 day ago: #{1.day.ago}"
        puts "user confirmed_at: #{unregistered.first.confirmed_at}"
        users = unregistered.select { |user| user.confirmed_at = 4.weeks.ago }
        users
    end

    def start_training_recipients
        users = User.registration_complete.not_started_training
        users
    end
end