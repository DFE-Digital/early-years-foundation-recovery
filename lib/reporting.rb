# https://tableconvert.com/csv-to-markdown
require 'csv'

module Reporting
  # ----------------------------------------------------------------------------

  # | registration_complete | registration_incomplete | reregistered | registered_since_private_beta | private_beta_only_registration_incomplete | private_beta_only_registration_complete | registration_events | private_beta_registration_events | public_beta_registration_events | total | locked_out | confirmed | unconfirmed | user_defined_roles | started_learning | not_started_learning |
  # |-----------------------|-------------------------|--------------|-------------------------------|-------------------------------------------|-----------------------------------------|---------------------|----------------------------------|---------------------------------|-------|------------|-----------|-------------|--------------------|------------------|----------------------|
  # | 1623                  | 1440                    | 411          | 1337                          | 229                                       | 1086                                    | 3127                | 1504                             | 1623                            | 3063  | 1          | 2930      | 133         | 78                 | 2072             | 991                  |
  #
  def export_users
    export('user_status', users.keys, [users.values])
  end

  # | id | not_started | started | in_progress | completed | module_start | module_complete | confidence_check_start | confidence_check_complete | start_assessment | pass_assessment | fail_assessment |
  # |----|-------------|---------|-------------|-----------|--------------|-----------------|------------------------|---------------------------|------------------|-----------------|-----------------|
  # | 1  | 992         | 2071    | 862         | 1209      | 2071         | 1209            | 776                    | 832                       | 799              | 623             | 171             |
  # | 2  | 2175        | 888     | 194         | 694       | 888          | 694             | 465                    | 480                       | 477              | 232             | 246             |
  # | 3  | 2525        | 538     | 82          | 456       | 538          | 456             | 316                    | 332                       | 318              | 108             | 211             |
  # | 4  | 2773        | 290     | 49          | 241       | 290          | 241             | 240                    | 240                       | 242              | 200             | 41              |
  #
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

      # closed accounts
      closed: User.closed.count,

      # devise
      locked_out: User.locked_out.count,
      confirmed: User.confirmed.count,
      unconfirmed: User.unconfirmed.count,

      # user input
      user_defined_roles: User.all.collect(&:role_type_other).uniq.count,

      # course engagement
      started_learning: started_learning,
      not_started_learning: not_started_learning,

      # Active users who have a least 1 note
      with_notes: with_notes_count,
      with_notes_percentage: with_notes_percentage,

      without_notes: without_notes_count,
      without_notes_percentage: 100 - with_notes_percentage,

    }
  end

  def modules
    mods.map do |mod|
      {
        id: mod.id,
        name: mod.name,
        title: mod.title,

        # module_time_to_completion
        not_started: not_started(mod),
        started: started(mod),
        in_progress: in_progress(mod),
        completed: completed(mod),

        true_false: true_false_count(mod),
        # module
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

  def mods
    if Rails.application.cms?
      Training::Module.ordered
    else
      TrainingModule.published
    end
  end

  def calculate_percentage(numerator, denominator)
    ((numerator.to_f / denominator) * 100).round(2)
  end

  def with_notes_percentage
    calculate_percentage(with_notes_count, User.not_closed.count)
  end

  def with_notes_count
    User.not_closed.with_notes.count
  end

  def without_notes_count
    User.not_closed.without_notes.count
  end

  def true_false_count(mod)
    return 'N/A' unless Rails.application.cms?

    mod.questions.count(&:true_false?)
  end
  #
  # @see ContentPagesController#track_events
  # @see ApplicationHelper#calculate_module_state
  # @see User#module_time_to_completion
  # ----------------------------------------------------------------------------

  # Number of users who have not started learning
  def not_started_learning
    User.all.map { |u| u.module_time_to_completion.keys }.count(&:empty?)
  end

  # Number of users who have started learning
  def started_learning
    User.all.map { |u| u.module_time_to_completion.keys }.count(&:present?)
  end

  # Number of users not started
  def not_started(mod)
    User.all.map { |u| u.module_time_to_completion[mod.name] }.count(&:nil?)
  end

  # Number of users in progress
  def in_progress(mod)
    User.all.map { |u| u.module_time_to_completion[mod.name] }.compact.count(&:zero?)
  end

  # Number of users completed
  def completed(mod)
    User.all.map { |u| u.module_time_to_completion[mod.name] }.compact.count(&:positive?)
  end

  # Number of users started
  def started(mod)
    in_progress(mod) + completed(mod)
  end
end
