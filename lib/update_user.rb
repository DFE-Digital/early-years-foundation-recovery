module UpdateUser
  # @param [Array<String>] emails
  def email_preferences_unsubscribe(emails)
    emails.each do |email|
      users = User.where(email: email)
      users.each do |user|
        if user.training_emails.nil?
          user.training_emails = false
        end
        user.save!
        if user.training_emails.nil?
          puts "User update unsuccessful for #{user.email}"
        end
      end
      puts "No user found with email: #{email}" if users.empty?
    end
  end
end
