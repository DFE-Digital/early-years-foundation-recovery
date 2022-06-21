class SeedInterimUsers
  def seed_interim_users
    seed_file = Rails.root.join('db/seeds/interim_data_best.yml')
    config = YAML.load_file(seed_file)
    config.each_slice(10) do |user_attributes|
      if !User.exists?(email: user_attributes["email"]) && valid_email?(user_attributes["email"])
        updated_attributes = user_attributes.merge(password: SecureRandom.base64(12))
        user = User.create!(updated_attributes)
        puts("User: #{user.email} succesfully created.")
        module_item = ModuleItem.where(training_module: 'child-development-and-the-eyfs').map(&:name)
        module_item.each do |page_name|
          view_module_page_event('child-development-and-the-eyfs', page_name, user)
        end
      elsif !(valid_email?(user_attributes["email"]))
        puts("Skipping user: #{user_attributes["email"]} creation as it is invalid.")
      else
        puts("Skipping user: #{user_attributes["email"]} creation as it already exists.")
      end
    end
  end

  def view_module_page_event(module_name, page_name, user)
    ahoy = Ahoy::Tracker.new(user: user, controller: 'content_pages')
    ahoy.track("Viewing #{page_name}", {
      id: page_name,
      action: 'show',
      controller: 'content_pages',
      training_module_id: module_name,
    })
    user.save!
  end

  EMAIL_REGEX = /\A[^@\s]+@[^@\s]+\z/

  def valid_email? email
    email =~ EMAIL_REGEX
  end
end
