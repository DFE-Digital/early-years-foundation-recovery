# https://tableconvert.com/csv-to-markdown
#
# :nocov:
require 'csv'

module Reporting
  # ----------------------------------------------------------------------------

  def export_users
    export('user_status', users.keys, [users.values])
  end

  def export_modules
    export('module_status', modules.first.keys, modules.map(&:values))
  end

  # ----------------------------------------------------------------------------

  def users
    {
      # registration scopes
      registration_complete: User.registration_complete.count,
      registration_incomplete: User.registration_incomplete.count,
      reregistered: User.reregistered.count,
      registered_since_private_beta: User.registered_since_private_beta.count,
      private_beta_only_registration_incomplete: User.private_beta_only_registration_incomplete.count,
      private_beta_only_registration_complete: User.private_beta_only_registration_complete.count,

      # registration events
      registration_events: Ahoy::Event.user_registration.count,
      private_beta_registration_events: Ahoy::Event.private_beta_registration.count,
      public_beta_registration_events: Ahoy::Event.public_beta_registration.count,

      # all
      total: User.all.count,

      # devise
      locked_out: User.locked_out.count,
      confirmed: User.confirmed.count,
      unconfirmed: User.unconfirmed.count,

      # user input
      user_defined_roles: User.all.collect(&:role_type_other).uniq.count,

      # course engagement
      started_learning: started_learning,
      not_started_learning: not_started_learning,
    }
  end

  def modules
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

        # NB: will not be present for legacy users
        module_start: Ahoy::Event.module_start.where_module(mod.name).count,
        module_complete: Ahoy::Event.module_complete.where_module(mod.name).count,

        # confidence
        confidence_check_start: Ahoy::Event.confidence_check_start.where_module(mod.name).count,
        confidence_check_complete: Ahoy::Event.confidence_check_complete.where_module(mod.name).count,

        # summative
        start_assessment: Ahoy::Event.summative_assessment_start.where_module(mod.name).count,
        pass_assessment: Ahoy::Event.summative_assessment_pass(mod.name).count,
        fail_assessment: Ahoy::Event.summative_assessment_fail(mod.name).count,
      }
    end
  end

private

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
end
# :nocov:

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
