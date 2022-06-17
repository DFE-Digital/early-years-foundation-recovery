def view_module_page_event(module_name, page_name, user)
  ahoy = Ahoy::Tracker.new(user: user, controller: 'content_pages')
  ahoy.track("Viewing #{page_name}", {
    id: page_name,
    action: 'show',
    controller: 'content_pages',
    training_module_id: module_name,
  })
  user.save
end

namespace :db do
  namespace :seed do
    desc 'Seed interim users data from yaml into database'
    task :interim_users => :environment do
      seed_file = Rails.root.join('db', 'seeds', 'interim_test_data.yml')
      config = YAML::load_file(seed_file)
      config.each do |user_attributes|
        user = User.create!(user_attributes)
        # Generate new random password for each user
        user.tap do |admin|
          admin.password = SecureRandom.base64(13)
        end
        user.save!
        # end
        module_item = ModuleItem.where(training_module: 'child-development-and-the-eyfs').map &:name
        module_item.each do |page_name|
          view_module_page_event('child-development-and-the-eyfs', page_name, user)
        end
      end
    end
  end
end
