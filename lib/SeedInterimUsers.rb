class SeedInterimUsers
  def self.seed_interim_users(users)
    users.each do |user_attributes|
      if !User.exists?(email: user_attributes['email']) && valid_email?(user_attributes['email'])
        updated_attributes = user_attributes.merge(password: SecureRandom.base64(12))
        user = User.create!(updated_attributes)
        puts ("User: #{user.email} succesfully created.")
        module_items = ModuleItem.where(training_module: 'child-development-and-the-eyfs').map(&:name)
        module_items.each do |page_name|
          view_module_page_event('child-development-and-the-eyfs', page_name, user)
        end
      elsif !(valid_email?(user_attributes['email']))
        puts ("Skipping user: #{user_attributes['email']} creation as it is invalid.")
      else
        puts ("Skipping user: #{user_attributes['email']} creation as it already exists.")
      end
    end
  end

  def self.view_module_page_event(module_name, page_name, user)
    ahoy = Ahoy::Tracker.new(user: user, controller: 'content_pages')
    ahoy.track("Viewing #{page_name}", {
      id: page_name,
      action: 'show',
      controller: 'content_pages',
      training_module_id: module_name,
    })
    user.save!
  end

  
  private
  
  EMAIL_REGEX = /\A[^@\s]+@[^@\s]+\z/

  def self.valid_email? email
    email =~ EMAIL_REGEX
  end
end
