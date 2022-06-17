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
        view_module_page_event('child-development-and-the-eyfs', '1-1', user)
        view_module_page_event('child-development-and-the-eyfs', '1-recap', user)
      end
    end
  end
end

