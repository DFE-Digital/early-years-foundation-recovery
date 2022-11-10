require 'csv'

module Reporting
  # ----------------------------------------------------------------------------

  def export_users
    export('user_status', users.keys, [users.values])
  end

  def export_modules
    export('module_status', modules.first.keys, modules.map(&:values))
  end

  def export(file_name, headers, rows)
    file_path = Rails.root.join("tmp/#{file_name}.csv")

    file_data = CSV.generate(headers: true) do |csv|
      csv << headers
      rows.each { |row| csv << row }
    end

    File.write(file_path, file_data)
    File.chmod(0o777, file_path)
    puts "#{file_path} created"
  end

  # ----------------------------------------------------------------------------

  def users
    {
      registered: registered,
      not_registered: not_registered,
      total: total,
      started_learning: started_learning,
      not_started_learning: not_started_learning,
    }
  end

  def modules
    # TrainingModule.active.map do |mod|
    TrainingModule.published.map do |mod|
      {
        id: mod.id,
        name: mod.name,
        title: mod.title,

        # User#module_time_to_completion
        # NB: will be present for legacy users (backfill rake task)
        not_started: not_started(mod),
        in_progress: in_progress(mod),
        completed: completed(mod),
        engagement: engagement(mod),

        # Ahoy::Events
        # NB: will not be present for legacy users
        module_start: module_start_event(mod),
        module_complete: module_complete_event(mod),
        confidence_check: confidence_check_complete_event(mod),
        pass_assessment: pass_summative_assessment_complete_event(mod),
        fail_assessment: fail_summative_assessment_complete_event(mod),
      }
    end
  end

  # @see User#registration_complete
  # ----------------------------------------------------------------------------

  def registered
    User.registered.count
  end

  def not_registered
    User.not_registered.count
  end

  def total
    User.all.count
  end

  #
  # @see ContentPagesController#track_events
  # @see ApplicationHelper#calculate_module_state
  # @see User#module_time_to_completion
  # ----------------------------------------------------------------------------

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

  # Number of users (total)
  def engagement(mod)
    in_progress(mod) + completed(mod)
  end

  # @see ContentPagesController#track_events
  # ----------------------------------------------------------------------------

  # Number of 'module_start' events
  def module_start_event(mod)
    Ahoy::Event.where(name: 'module_start').where_properties(training_module_id: mod.name).count
  end

  # Number of 'module_complete' events
  def module_complete_event(mod)
    Ahoy::Event.where(name: 'module_complete').where_properties(training_module_id: mod.name).count
  end

  # Number of 'confidence_check_complete' events
  def confidence_check_complete_event(mod)
    Ahoy::Event.where(name: 'confidence_check_complete').where_properties(training_module_id: mod.name).count
  end

  # @see AssessmentResultsController#track_events
  # ----------------------------------------------------------------------------

  # Number of PASS 'summative_assessment_complete' events
  def pass_summative_assessment_complete_event(mod)
    Ahoy::Event.where(name: 'summative_assessment_complete').where_properties(training_module_id: mod.name, success: true).count
  end

  # Number of FAIL 'summative_assessment_complete' events
  def fail_summative_assessment_complete_event(mod)
    Ahoy::Event.where(name: 'summative_assessment_complete').where_properties(training_module_id: mod.name, success: false).count
  end
end

namespace :report do
  include Reporting

  desc 'print stats to console [YAML]'
  task stats: :environment do
    puts users.to_yaml
    puts modules.to_yaml
  end

  desc 'export stats to file [CSV]'
  task export: :environment do
    export_users
    export_modules
  end
end
