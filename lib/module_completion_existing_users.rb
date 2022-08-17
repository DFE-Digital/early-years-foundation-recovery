class ModuleCompletionExistingUsers
  modules = [
    ['child-development-and-the-eyfs', 'intro', '1-3-2-6'],
    ['brain-development-and-how-children-learn', 'intro', '2-3-3-5'],
    ['personal-social-and-emotional-development', 'intro', '3-4-3-7'],
  ]
  
  def calculate_completion_time(modules)
    users = User.all
    users.each do |user|
      modules.each do |module_name, start_page, end_page|
        mod_time = CompletionTimeExistingUsers.new(user: user, training_module_id: module_name, start_page: start_page, end_page: end_page)
        mod_time.update_time(module_name)
      end
    end
  end
end