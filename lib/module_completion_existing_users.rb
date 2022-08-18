class ModuleCompletionExistingUsers
  def calculate_completion_time(modules)
    users = User.all
    
    users.each do |user|
      mod_time = CompletionTimeExistingUsers.new(user: user, modules: modules)
      mod_time.update_time(modules)
    end
  end
end