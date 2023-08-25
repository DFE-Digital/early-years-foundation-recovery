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
    registration_complete
    private_beta_registration_complete
    registration_complete_any?
    registered_at
    terms_and_conditions_agreed_at
  ].freeze

  # @return [Array<String>]
  def self.dashboard_headers
    DASHBOARD_ATTRS + Training::Module.live.map { |mod| "module_#{mod.position}_time" }
  end

  # Include default devise modules. Others available are:
  # :timeoutable, :trackable, :recoverable and :omniauthable
  attr_accessor :context

  devise :database_authenticatable, :registerable, :recoverable,
         :validatable, :rememberable, :confirmable, :lockable, :timeoutable

  has_many :responses
  has_many :user_answers

  has_many :user_assessments
  has_many :visits, class_name: 'Ahoy::Visit'
  has_many :events, class_name: 'Ahoy::Event'
  has_many :notes

  # TODO: use scope with email alert
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

  # new users only
  scope :public_beta_only_registration_complete, -> { registered_since_private_beta.registration_complete }

  scope :since_public_beta, -> { where(created_at: Rails.application.public_beta_launch_date..Time.zone.now) }

  scope :confirmed, -> { where.not(confirmed_at: nil) }
  scope :unconfirmed, -> { where(confirmed_at: nil) }
  scope :locked_out, -> { where.not(locked_at: nil) }
  scope :since_public_beta, -> { where(created_at: Rails.application.public_beta_launch_date..Time.zone.now) }
  scope :month_old_confirmation, -> { where(confirmed_at: 4.weeks.ago.beginning_of_day..4.weeks.ago.end_of_day) }
  scope :with_local_authority, -> { where.not(local_authority: nil) }
  scope :with_notes, -> { joins(:notes).distinct.select(&:has_notes?) }
  scope :not_started_training, -> { reject(&:course_started?) }
  scope :course_in_progress, -> { select(&:course_in_progress?) }

  scope :training_email_recipients, -> { where(training_emails: [true, nil]) }
  scope :early_years_email_recipients, -> { where(early_years_emails: true) }
  scope :without_notes, -> { where.not(id: with_notes) }

  scope :closed, -> { where.not(closed_at: nil) }
  scope :not_closed, -> { where(closed_at: nil) }
  validates :closed_reason, presence: true, if: -> { context == :close_account }
  validates :closed_reason_custom, presence: true, if: proc { |u| u.closed_reason == 'other' }

  scope :with_assessments, -> { joins(:user_assessments) }
  scope :with_passing_assessments, -> { with_assessments.merge(UserAssessment.passes) }

  scope :start_training_recipients, -> { training_email_recipients.month_old_confirmation.registration_complete.not_started_training }
  # scope :complete_registration_recipients, -> { training_email_recipients.month_old_confirmation.registration_incomplete }
  # TODO: change back to the above scope before merging
  scope :complete_registration_recipients, -> { training_email_recipients.registration_incomplete }
  scope :continue_training_recipients, -> { training_email_recipients.select(&:continue_training_recipient?) }
  scope :completed_available_modules, -> { training_email_recipients.select(&:completed_available_modules?) }

  scope :dashboard, -> { not_closed }

  validates :first_name, :last_name, :setting_type_id,
            presence: true,
            if: proc { |u| u.registration_complete? }
  validates :role_type, presence: true, if: proc { |u| u.role_type_required? }
  validates :setting_type_id,
            inclusion: { in: Trainee::Setting.valid_types },
            if: proc { |u| u.registration_complete? }

  validates :terms_and_conditions_agreed_at, presence: true, allow_nil: false, on: :create

  # @return [Boolean]
  def has_notes?
    notes.any?(&:filled?)
  end

  # @see Devise database_authenticatable
  # @param params [Hash]
  # @return [Boolean]
  def update_with_password(params)
    if params[:password].blank?
      errors.add :password, :blank
      return false
    end

    super
  end

  # @see ResponsesController#response_params
  # @param content [Training::Question]
  # @return [UserAnswer, Response]
  def response_for(content)
    if ENV['DISABLE_USER_ANSWER'].present?
      responses.find_or_initialize_by(
        question_name: content.name,
        training_module: content.parent.name,
        archived: false,
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

  # @see Devise::Confirmable
  # send_confirmation_instructions
  def send_confirmation_instructions
    unless @raw_confirmation_token
      generate_confirmation_token!
    end

    opts = pending_reconfirmation? ? { to: unconfirmed_email } : {}
    mailer = registration_complete? ? :email_confirmation_instructions : :activation_instructions
    send_devise_notification(mailer, @raw_confirmation_token, opts)
  end

  # send email to registered user if attempt is made to create account with registered email
  def send_email_taken_notification
    send_devise_notification(:email_taken)
  end

  def send_account_closed_notification
    send_devise_notification(:account_closed)
  end

  def send_new_module_notification(mod)
    send_devise_notification(:new_module, mod)
  end

  # TODO: refactor this internal user mailer logic
  def send_account_closed_internal_notification(user_account_email)
    send_devise_notification(:account_closed_internal, user_account_email)
  end

  # @return [String]
  def name
    [first_name, last_name].compact.join(' ')
  end

  # @return [String]
  def email_to_confirm
    pending_reconfirmation? ? unconfirmed_email : email
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
  def course_in_progress?
    course_started? && !module_time_to_completion.values.all?(&:positive?)
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
    (local_authority.presence || 'Multiple')
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
    return true if select_new_role?
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
    skip_reconfirmation!
    skip_email_changed_notification!
    skip_password_change_notification!
    update!(first_name: 'Redacted',
            last_name: 'User',
            email: "redacted_user#{id}@example.com",
            closed_at: Time.zone.now,
            password: 'redacteduser')

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
    return unless course_in_progress?

    recent_visits = Ahoy::Visit.last_4_weeks
    old_visits = Ahoy::Visit.month_old.reject { |visit| recent_visits.pluck(:user_id).include?(visit.user_id) }
    old_visits.pluck(:user_id).include?(id)
  end

private

  # @return [Hash]
  def data_attributes
    DASHBOARD_ATTRS.map { |field| { field => send(field) } }.reduce(&:merge)
  end

  # @return [Ahoy::Event::ActiveRecord_AssociationRelation]
  def password_changed_events
    events.where(name: 'user_password_change')
  end
end
