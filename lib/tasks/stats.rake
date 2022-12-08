# https://tableconvert.com/csv-to-markdown
#
# :nocov:
require 'csv'

module Reporting
  # ----------------------------------------------------------------------------

  #
  # | registered | not_registered | total | started_learning | not_started_learning |
  # |------------|----------------|-------|------------------|----------------------|
  # | 1          | 0              | 3     | 0                | 1                    |
  #
  def export_users
    export('user_status', users.keys, [users.values])
  end

  #
  # | id | name                                      | title                                                              | not_started | in_progress | completed | engagement | module_start | module_complete | confidence_check | pass_assessment | fail_assessment |
  # |----|-------------------------------------------|--------------------------------------------------------------------|-------------|-------------|-----------|------------|--------------|-----------------|------------------|-----------------|-----------------|
  # | 1  | child-development-and-the-eyfs            | Understanding child development and the EYFS                       | 1           | 0           | 0         | 0          | 0            | 0               | 0                | 0               | 0               |
  # | 2  | brain-development-and-how-children-learn  | Brain development and how children learn                           | 1           | 0           | 0         | 0          | 0            | 0               | 0                | 0               | 0               |
  # | 3  | personal-social-and-emotional-development | "Supporting children’s personal, social and emotional development" | 1           | 0           | 0         | 0          | 0            | 0               | 0                | 0               | 0               |
  # | 4  | module-4                                  | Supporting language development in the early years                 | 1           | 0           | 0         | 0          | 0            | 0               | 0                | 0               | 0               |
  #
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
      # registration scopes
      registration_complete: registration_complete,
      registration_incomplete: registration_incomplete,
      reregistered: reregistered,
      registered_since_private_beta: registered_since_private_beta,
      private_beta_only_registration_incomplete: private_beta_only_registration_incomplete,
      private_beta_only_registration_complete: private_beta_only_registration_complete,

      # all
      total: total,

      started_learning: started_learning,
      not_started_learning: not_started_learning,

      user_defined_roles: user_defined_roles,

      # devise
      locked_out: locked_out,
      confirmed: confirmed,
      unconfirmed: unconfirmed,

      # events
      private_beta_registration_events: private_beta_registration_events,
      public_beta_registration_events: public_beta_registration_events,
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
        # confidence
        confidence_check_start: confidence_check_start_event(mod),
        confidence_check_complete: confidence_check_complete_event(mod),
        # summative
        pass_assessment: pass_summative_assessment_complete_event(mod),
        fail_assessment: fail_summative_assessment_complete_event(mod),
      }
    end
  end

  # @see User#registration_complete
  # ----------------------------------------------------------------------------

  def registration_complete
    User.registration_complete.count
  end

  def registration_incomplete
    User.registration_incomplete.count
  end

  def reregistered
    User.reregistered.count
  end

  def registered_since_private_beta
    User.registered_since_private_beta.count
  end

  def private_beta_only_registration_complete
    User.private_beta_only_registration_complete.count
  end

  def private_beta_only_registration_incomplete
    User.private_beta_only_registration_incomplete.count
  end

  def total
    User.all.count
  end

  def confirmed
    User.where.not(confirmed_at: nil).count
  end

  def unconfirmed
    User.where(confirmed_at: nil).count
  end

  def locked_out
    User.where.not(locked_at: nil).count
  end

  def user_defined_roles
    Ahoy::Event.where(name: 'user_registration').where_properties(controller: 'registration/role_type_others').map { |e| e.user.role_type_other }.uniq.count
  end

  def private_beta_registration_events
    Ahoy::Event.where(name: 'user_registration').where_properties(controller: 'extra_registrations').count
  end

  def public_beta_registration_events
    controllers = %w[
      registration/role_types
      registration/role_type_others
      registration/local_authorities
      registration/setting_types
    ]

    controllers.map { |c| Ahoy::Event.where(name: 'user_registration').where_properties(controller: c).count }.reduce(&:+)
  end

  #
  # @see ContentPagesController#track_events
  # @see ApplicationHelper#calculate_module_state
  # @see User#module_time_to_completion
  # ----------------------------------------------------------------------------

  # Number of registered users who have not started learning
  def not_started_learning
    User.registration_complete.map { |u| u.module_time_to_completion.keys }.count(&:empty?)
  end

  # Number of registered users who have started learning
  def started_learning
    User.registration_complete.map { |u| u.module_time_to_completion.keys }.count(&:present?)
  end

  # Number of users not started
  def not_started(mod)
    User.registration_complete.map { |u| u.module_time_to_completion[mod.name] }.count(&:nil?)
  end

  # Number of users in progress
  def in_progress(mod)
    User.registration_complete.map { |u| u.module_time_to_completion[mod.name] }.compact.count(&:zero?)
  end

  # Number of users completed
  def completed(mod)
    User.registration_complete.map { |u| u.module_time_to_completion[mod.name] }.compact.count(&:positive?)
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

  # @see QuestionnairesController#track_events
  # ----------------------------------------------------------------------------

  # Number of 'confidence_check_start' events
  def confidence_check_start_event(mod)
    Ahoy::Event.where(name: 'confidence_check_start').where_properties(training_module_id: mod.name).count
  end

  # Number of 'summative_assessment_start' events
  def summative_assessment_start_event(mod)
    Ahoy::Event.where(name: 'summative_assessment_start').where_properties(training_module_id: mod.name).count
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

namespace :eyfs do
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
end
# :nocov:
