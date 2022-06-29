class SeedInterimUsers
  def seed_interim_users
    seed_file = Rails.root.join('db/seeds/interim_data.yml')
    users = YAML.load_file(seed_file)
    users.each do |user_attributes|
      if !User.exists?(email: user_attributes['email']) && valid_email?(user_attributes['email'])
        updated_attributes = user_attributes.merge(password: ENV.fetch('INTERIM_PASSWORD', 'StrongPassword'), confirmed_at: '2022-06-16 00:00:00')
        user = User.create!(updated_attributes)
        puts("User: #{user.email} succesfully created.")
        module_items = ModuleItem.where(training_module: 'child-development-and-the-eyfs')
        module_items.each do |item|
          break if item.name == '1-3-2'

          view_module_page_event('child-development-and-the-eyfs', item.name, user)
        end
      elsif !valid_email?(user_attributes['email'])
        puts("Skipping user: #{user_attributes['email']} creation as it is invalid.")
      else
        puts("Skipping user: #{user_attributes['email']} creation as it already exists.")
      end
    end
  end

  def view_module_page_event(module_name, page_name, user)
    ahoy = Ahoy::Tracker.new(user: user, controller: 'content_pages')
    ahoy.track('module_content_page', {
      id: page_name,
      action: 'show',
      controller: 'content_pages',
      training_module_id: module_name,
      seed: true,
    })
    user.save!
  end

  EMAIL_REGEX = /\A[^@\s]+@[^@\s]+\z/

  def valid_email?(email)
    email =~ EMAIL_REGEX
  end
end
