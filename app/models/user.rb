class User < ApplicationRecord
  include ToCsv

  # @return [Array<String>] non-identifiable attributes for KPI tracking
  DASHBOARD_ATTRS = %w[
    id
    local_authority
    setting_type
    setting_type_other
    role_type
    role_type_other
    early_years_experience
    registration_complete
    private_beta_registration_complete
    registration_complete_any?
    registered_at
    terms_and_conditions_agreed_at
    training_emails
    early_years_emails
    email_delivery_status
    gov_one?
  ].freeze

  # @return [Array<String>]
  def self.dashboard_headers
    DASHBOARD_ATTRS + Training::Module.live.map { |mod| "module_#{mod.position}_time" }
  end

  # @return [String]
  def self.random_password
    special_characters = ['!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '-', '_', '=', '+']
    SecureRandom.alphanumeric(5).upcase + SecureRandom.alphanumeric(5).downcase + special_characters.sample(3).join + SecureRandom.hex(5)
  end

  # @param email [String]
  # @param gov_one_id [String]
  # @return [User]
  def self.find_or_create_from_gov_one(email:, gov_one_id:)
    if (user = find_by(email: email) || find_by(gov_one_id: gov_one_id))
      user.update_column(:email, email)
      user.update_column(:gov_one_id, gov_one_id) if user.gov_one_id.nil?
    else
      user = new(
        email: email,
        gov_one_id: gov_one_id,
        confirmed_at: Time.zone.now,
        password: random_password,
      )
    end
    user.save!
    user
  end

  # @return [User]
  def self.test_user
    find_by(email: 'completed@example.com')
  end

  # @return [Boolean]
  def test_user?
    email == 'completed@example.com'
  end

  attr_accessor :context

  devise :database_authenticatable, :rememberable, :lockable, :timeoutable,
         :omniauthable, omniauth_providers: [:openid_connect]

  has_many :responses
  has_many :user_answers

  if Rails.application.migrated_answers?
    has_many :assessments
  else
    has_many :user_assessments
  end

  has_many :visits
  has_many :events
  has_many :mail_events
  has_many :notes

  scope :gov_one, -> { where.not(gov_one_id: nil) }

  # account status
  scope :public_beta_only_registration_complete, -> { registered_since_private_beta.registration_complete }
  scope :since_public_beta, -> { where(created_at: Rails.application.public_beta_launch_date..Time.zone.now) }
  scope :confirmed, -> { where.not(confirmed_at: nil) }
  scope :unconfirmed, -> { where(confirmed_at: nil) }
  scope :locked_out, -> { where.not(locked_at: nil) }
  scope :closed, -> { where.not(closed_at: nil) }
  scope :not_closed, -> { where(closed_at: nil) }
  # created an account within public beta but still not using service
  scope :registration_incomplete, -> { where(registration_complete: false) }
  # completed registration within public beta (may include private beta users)
  scope :registration_complete, -> { where(registration_complete: true) }
  # @note
  #   The default for :registration_complete was originally nil,
  #   when the registration journey was revised,
  #   the existing :registration_complete boolean was renamed,
  #   and the default changed to false
  #
  scope :registered_since_private_beta, -> { where(private_beta_registration_complete: false) }
  # completed registration in both private and public beta
  scope :reregistered, -> { where(private_beta_registration_complete: true, registration_complete: true) }
  # only registered to completion within private beta
  scope :private_beta_only_registration_complete, -> { where(private_beta_registration_complete: true, registration_complete: false) }
  # registered within private beta but never completed
  scope :private_beta_only_registration_incomplete, -> { where(private_beta_registration_complete: nil) }
  scope :registration_complete_all_users, -> { registration_complete.or(where(private_beta_registration_complete: true)) }

  # training activity
  scope :not_started_training, -> { reject(&:course_started?) }
  scope :course_in_progress, -> { select(&:course_in_progress?) }

  # notes
  scope :with_notes, -> { joins(:notes).merge(Note.filled) }
  scope :without_notes, -> { where.not(id: with_notes) }

  # assessments
  if Rails.application.migrated_answers?
    scope :with_assessments, -> { joins(:assessments) }
    scope :with_passing_assessments, -> { with_assessments.merge(Assessment.passed) }
  else
    scope :with_assessments, -> { joins(:user_assessments) }
    scope :with_passing_assessments, -> { with_assessments.merge(UserAssessment.passes) }
  end

  # events
  scope :with_events, -> { joins(:events) }
  scope :with_module_start_events, -> { with_events.merge(Event.module_start) }
  scope :with_module_complete_events, -> { with_events.merge(Event.module_complete) }
  scope :completed_available_modules, -> { with_module_complete_events.group('users.id').having('count(ahoy_events.id) = ?', ModuleRelease.count) }
  scope :started_training, -> { with_module_start_events.distinct }
  scope :not_started_training, -> { where.not(id: with_module_start_events) }

  # visits
  scope :with_visits, -> { joins(:visits) }
  scope :visits_within_month, -> { with_visits.merge(Visit.within_4_weeks).distinct }
  scope :month_old_visits, -> { with_visits.merge(Visit.month_old).distinct }
  scope :no_visits_this_month, -> { where.not(id: visits_within_month) }
  scope :last_visit_4_weeks_ago, -> { where(id: month_old_visits).where.not(id: visits_within_month) }

  # emails
  scope :training_email_recipients, -> { order(:id).where(training_emails: [true, nil]).distinct }
  scope :early_years_email_recipients, -> { order(:id).where(early_years_emails: true).distinct }
  scope :complete_registration_mail_job_recipients, -> { training_email_recipients.month_old_confirmation.registration_incomplete.distinct }
  scope :start_training_mail_job_recipients, -> { training_email_recipients.month_old_confirmation.registration_complete.not_started_training.distinct }
  scope :continue_training_mail_job_recipients, -> { training_email_recipients.last_visit_4_weeks_ago.distinct(&:module_in_progress?) }

  # @note
  #
  #   Bulk mail like 'New Module' publication notifications are sent to nearly the entire dataset.
  #   In order to prevent duplicate messages in the event of an exception causing the job to restart
  #   or the worker container crashing, we exclude users from the recipient list if a delivered MailEvent exists
  #   or if a queued mail delivery Job exists.
  #
  scope :new_module_mail_job_recipients, lambda {
    training_email_recipients.not_closed
    .where.not(id: with_new_module_mail_events)
    .where.not(id: Job.newest_module_mail.map(&:mail_user_id))
    .distinct
  }

  # @note prefix/suffix ensures testing of invalid email
  # @example "person@education.gov.uk."
  scope :test_bulk_mail_job_recipients, -> { where("lower(email) LIKE '%@education.gov.uk%'").distinct }

  # email callbacks
  scope :with_mail_events, -> { joins(:mail_events) }
  scope :with_new_module_mail_events, -> { with_mail_events.merge(MailEvent.newest_module).distinct }

  scope :email_delivered, lambda {
    training_email_recipients.or(early_years_email_recipients).where('notify_callback @> ?', { notification_type: 'email', status: 'delivered' }.to_json).distinct
  }
  scope :email_delivered_days_ago, lambda { |num|
    email_delivered.where("CAST(notify_callback ->> 'sent_at' AS DATE) = CURRENT_DATE - #{num}")
  }
  scope :email_delivered_today, -> { email_delivered_days_ago(0) }
  scope :last_email_delivered, lambda { |template_id|
    email_delivered.where('notify_callback @> ?', { template_id: template_id }.to_json)
  }

  # data
  scope :dashboard, -> { not_closed }
  scope :month_old_confirmation, -> { where(confirmed_at: 4.weeks.ago.beginning_of_day..4.weeks.ago.end_of_day) }
  scope :with_local_authority, -> { where.not(local_authority: nil) }

  validates :closed_reason, presence: true, if: -> { context == :close_account }
  validates :closed_reason_custom, presence: true, if: proc { |u| u.closed_reason == 'other' }

  validates :first_name, :last_name, :setting_type_id,
            presence: true,
            if: proc { |u| u.registration_complete? }
  validates :role_type, presence: true, if: proc { |u| u.role_type_required? }
  validates :setting_type_id,
            inclusion: { in: Trainee::Setting.valid_types },
            if: proc { |u| u.registration_complete? }

  validates :terms_and_conditions_agreed_at, presence: true, allow_nil: false, on: :update, if: proc { |u| u.registration_complete? }

  # @return [Boolean]
  def notes?
    notes.any?(&:filled?)
  end

  # @return [Boolean]
  def gov_one?
    !gov_one_id.nil?
  end

  # @return [Boolean]
  def guest?
    false
  end

  # @see FeedbackPaginationDecorator
  #
  # Checks all feedback forms for answers
  #
  # @param question [Training::Question]
  # @return [Boolean]
  def skip_question?(question)
    return false unless question.skippable?

    (Training::Module.live.to_a << Course.config).any? do |form|
      response_for_shared(question, form).responded?
    end
  end

  # @see ResponsesController#response_params
  # @param content [Training::Question]
  # @return [UserAnswer, Response]
  def response_for_shared(content, mod)
    responses.find_or_initialize_by(
      question_type: content.page_type,
      question_name: content.name,
      training_module: mod.name,
    )
  end

  # @see ResponsesController#response_params
  # @param content [Training::Question]
  # @return [UserAnswer, Response]
  def response_for(content)
    if Rails.application.migrated_answers?
      if content.summative_question?
        # creates new assessment on first summative_question
        assessment =
          assessments.passed.find_by(training_module: content.parent.name) ||
          assessments.incomplete.find_by(training_module: content.parent.name) || # needed?
          assessments.create(training_module: content.parent.name, started_at: Time.zone.now)
      end

      responses.find_or_initialize_by(
        assessment_id: assessment&.id,
        training_module: content.parent.name,
        question_name: content.name,
        question_type: content.question_type, # TODO: RENAME options for Question#page_type removing "questionnaire" suffix
      )
    else
      user_answers.find_or_initialize_by(
        assessments_type: content.assessments_type,
        module: content.parent.name,
        name: content.name,
        questionnaire_id: 0,
        question: 'N/A for CMS only questions',
        archived: nil,
      )
    end
  end

  # @return [Array<Training::Module>]
  def active_modules
    Training::Module.live.select do |mod|
      module_time_to_completion.key?(mod.name)
    end
  end

  # @return [String]
  def name
    [first_name, last_name].compact.join(' ')
  end

  # @return [String]
  def email_delivery_status
    notify_callback.to_h.fetch('status', 'unknown')
  end

  # @return [String]
  def password_last_changed
    timestamp = password_changed_events&.last&.time || created_at
    timestamp.to_date&.to_formatted_s(:rfc822)
  end

  # @return [CourseProgress] course activity query interface
  def course
    @course ||= CourseProgress.new(user: self)
  end

  # @return [Boolean]
  def course_started?
    !module_time_to_completion.empty?
  end

  # @return [Boolean]
  def module_in_progress?
    course_started? && !module_time_to_completion.values.all?(&:positive?)
  end

  # @return [Array<String>]
  def modules_in_progress
    module_time_to_completion.select { |_k, v| v.zero? }.keys
  end

  # @param module_name [String]
  # @return [Boolean]
  def module_completed?(module_name)
    module_time_to_completion.key?(module_name) && module_time_to_completion[module_name].positive?
  end

  # @return [Integer]
  def modules_completed
    module_time_to_completion.values.count(&:positive?)
  end

  # @return [String]
  def authority_name
    local_authority.presence || 'Multiple'
  end

  # @return [String]
  def setting_name
    setting_other? ? setting_type_other : setting.title
  end

  # @return [String]
  def role_name
    role_other? ? role_type_other : role_type
  end

  # @return [Boolean]
  def childminder?
    setting_other? ? false : setting.role_type.eql?('childminder')
  end

  # @return [Boolean]
  def role_type_required?
    return false unless setting_type_id
    return false unless registration_complete?
    return true if setting_other?
    return false unless setting_valid?

    true if select_new_role?
  end

  # @return [Boolean]
  def setting_valid?
    Trainee::Setting.valid_types.include?(setting_type_id)
  end

  # @return [Boolean]
  def select_new_role?
    return false unless setting_type_id_changed?

    new_value = setting_type_id_change[1]

    Trainee::Setting.by_name(new_value).has_role?
  end

  # @return [Boolean]
  def setting_local_authority?
    setting_type_id == 'local_authority'
  end

  # @return [Boolean]
  def setting_other?
    setting_type_id == 'other'
  end

  # @return [Boolean]
  def role_other?
    role_type == 'other'
  end

  # @return [Boolean]
  def role_applicable?
    role_type != 'Not applicable'
  end

  # return [Boolean]
  def training_emails_recipient?
    training_emails || training_emails.nil?
  end

  # return [Boolean]
  def research_participant?
    response = responses.feedback.find { |preference| preference.question.skippable? }
    if response.nil?
      update(research_participant: false)
      false
    else
      option = response.question.options(checked: response.answers).find(&:checked?)
      opt_in = option.id.eql?(1)
      update(research_participant: opt_in)
      opt_in
    end
  end

  # @return [Boolean]
  def private_beta_registration_complete?
    !!private_beta_registration_complete
  end

  # @return [Boolean]
  def registration_complete_any?
    private_beta_registration_complete? || !!registration_complete
  end

  # @return [Datetime]
  def registered_at
    events.where(name: 'user_registration').first&.time # :first returns private_beta or public_beta if that is the only one
  end

  # @return [Trainee::Setting, nil]
  def setting
    return unless setting_type_id

    Trainee::Setting.by_name(setting_type_id)
  end

  # @return [Boolean]
  def email_preferences_complete?
    !training_emails.nil?
  end

  # @return [Hash{Symbol => Integer}]
  def module_ttc
    Training::Module.live.map(&:name).index_with do |mod|
      module_time_to_completion[mod]
    end
  end

  def redact!
    update!(first_name: 'Redacted',
            last_name: 'User',
            email: "redacted_user#{id}@example.com",
            closed_at: Time.zone.now,
            password: 'RedactedUser12!@')

    notes.destroy_all
  end

  # @see ToCsv#dashboard_row
  # @return [Hash] override
  def dashboard_row
    data_attributes.dup.merge(module_ttc)
  end

  # @return [Boolean]
  def completed_available_modules?
    available_modules = ModuleRelease.pluck(:name)
    available_modules.all? { |mod_name| module_completed?(mod_name) }
  end

  # @return [Boolean]
  def continue_training_recipient?
    recent_visits = Visit.last_4_weeks
    old_visits = Visit.month_old.reject { |visit| recent_visits.pluck(:user_id).include?(visit.user_id) }
    old_visits.pluck(:user_id).include?(id)
  end

  # @return [VisitChanges] changes since last visit
  def content_changes
    @content_changes ||= ContentChanges.new(user: self)
  end

  # @return [Boolean]
  def completed_course_feedback?
    responses.course_feedback.count.eql? Course.config.feedback_questions.count
  end

  # @return [String]
  def visit_token
    visits.last.visit_token
  end

private

  # @return [Hash]
  def data_attributes
    DASHBOARD_ATTRS.map { |field| { field => send(field) } }.reduce(&:merge)
  end

  # @return [Event::ActiveRecord_AssociationRelation]
  def password_changed_events
    events.where(name: 'user_password_change')
  end
end
