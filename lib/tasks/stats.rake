module Reporting
  def users
    {
      users: {
        registered: registered,
        not_registered: not_registered,
        total: total,
        started_learning: started_learning,
        not_started_learning: not_started_learning,
      },
    }
  end

  def modules
    TrainingModule.published.map do |mod|
      {
        id: mod.id,
        name: mod.name,
        title: mod.title,
        not_started: not_started(mod),
        in_progress: in_progress(mod),
        completed: completed(mod),
        engagement: engagement(mod),
      }
    end
  end

private

  def registered
    User.registered.count
  end

  def not_registered
    User.not_registered.count
  end

  def total
    User.all.count
  end

  # Number of registered users who have not started learning
  def not_started_learning
    User.registered.map { |u| u.module_time_to_completion.keys }.count(&:empty?)
  end

  # Number of registered users who have started learning
  def started_learning
    User.registered.map { |u| u.module_time_to_completion.keys }.count(&:present?)
  end

  # Number of users not started
  def not_started(mod)
    User.registered.map { |u| u.module_time_to_completion[mod.name] }.count(&:nil?)
  end

  # Number of users in progress
  def in_progress(mod)
    User.registered.map { |u| u.module_time_to_completion[mod.name] }.compact.count(&:zero?)
  end

  # Number of users completed
  def completed(mod)
    User.registered.map { |u| u.module_time_to_completion[mod.name] }.compact.count(&:positive?)
  end

  def engagement(mod)
    in_progress(mod) + completed(mod)
  end

  # def started(mod)
  #   Ahoy::Event.where(name: 'module_start').where_properties(training_module_id: mod.name).count
  # end

  # def completed(mod)
  #   Ahoy::Event.where(name: 'module_complete').where_properties(training_module_id: mod.name).count
  # end
end

namespace :report do
  desc 'report all stats'
  task stats: :environment do
    include Reporting

    pp users
    pp modules

    puts users.to_yaml
    puts modules.to_yaml
  end
end
