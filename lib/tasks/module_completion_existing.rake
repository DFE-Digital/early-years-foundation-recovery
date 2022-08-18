require 'module_completion_existing_users'

namespace :db do
  desc 'Calculate module completion time for existing users'
  modules = [
    ['child-development-and-the-eyfs', '1-3-2-6'],
    ['brain-development-and-how-children-learn', '2-3-3-5'],
    ['personal-social-and-emotional-development', '3-4-3-7'],
  ]
  task calculate_completion_time: :environment do
    ModuleCompletionExistingUsers.new.calculate_completion_time(modules)
  end
end