class User < ApplicationRecord
  include ToCsv

  # @return [Array<String>] non-identifiable attributes for KPI tracking
  DASHBOARD_ATTRS = %w[
    id
    local_authority
    setting_type
    role_type
    registration_complete
    private_beta_registration_complete
    registration_complete_any
    registered_at
  ].freeze

  # Collate published module state and profile data in CSV format
  #
  # @overload to_csv
  # @see ToCsv.to_csv
  #   @return [String]
  def self.to_csv
    module_headings =
      if Rails.application.cms?
        Training::Module.ordered.reject(&:draft?).map { |mod| "module_#{mod.position}_time" }
      else
        TrainingModule.published.map { |mod| "module_#{mod.id}_time" }
      end

    CSV.generate(headers: true) do |csv|
      csv << (DASHBOARD_ATTRS + module_headings)

      dashboard.find_each(batch_size: 1_000) do |record|
        csv << (record.dashboard_attributes.values + record.module_ttc)
      end
    end
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

  # scope :dashboard, -> { where.not(closed_at: nil) }

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

  scope :confirmed, -> { where.not(confirmed_at: nil) }
  scope :unconfirmed, -> { where(confirmed_at: nil) }
  scope :locked_out, -> { where.not(locked_at: nil) }
  scope :since_public_beta, -> { where(created_at: Rails.application.public_beta_launch_date..Time.zone.now) }
  scope :with_local_authority, -> { where.not(local_authority: nil) }
  scope :with_notes, -> { joins(:notes).distinct.select(&:has_notes?) }
  scope :with_assessments, -> { joins(:user_assessments) }

  validates :first_name, :last_name, :setting_type_id,
            presence: true,
            if: proc { |u| u.registration_complete }
  validates :role_type, presence: true, if: proc { |u| u.role_type_required? }
  validates :setting_type_id,
            inclusion: { in: SettingType.valid_setting_types },
            if: proc { |u| u.registration_complete }
  validates :closed_reason, presence: true, if: -> { context == :close_account }
  validates :closed_reason_custom, presence: true, if: proc { |u| u.closed_reason == 'other' }

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
      questionnaire = Questionnaire.find_by!(name: content.name, training_module: content.parent.name)

      user_answers.find_or_initialize_by(
        assessments_type: content.assessments_type,
        module: content.parent.name,
        name: content.name,
        questionnaire_id: questionnaire.id,
        question: questionnaire.questions.keys.first,
        archived: nil,
      )
    end
  end

  # @return [Array<Training::Modules>]
  def active_modules
    Training::Module.ordered.reject(&:draft?).select { |mod| module_time_to_completion.key?(mod.name) }
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

  # @return [CourseProgress, ContentfulCourseProgress] course activity query interface
  def course
    @course ||= if Rails.application.cms?
                  ContentfulCourseProgress.new(user: self)
                else
                  CourseProgress.new(user: self)
                end
  end

  # @return [Boolean]
  def course_started?
    !module_time_to_completion.empty?
  end

  # @return [String]
  def setting_name
    setting_type_id == 'other' ? setting_type_other : setting_type
  end

  # @return [Boolean]
  def role
    role_type == 'other' ? role_type_other : role_type
  end

  # @return [Boolean]
  def childminder?
    setting_type_id == 'other' ? false : setting.role_type.eql?('childminder')
  end

  # @return [Boolean]
  def role_type_required?
    return false unless setting_type_id
    return false unless registration_complete?
    return true if setting_type_id == 'other'
    return false unless SettingType.valid_setting_types.include?(setting_type_id)
    return true if new_setting_type_role_required?

    setting.role_type != 'none'
  end

  # @return [Boolean]
  def new_setting_type_role_required?
    if setting_type_id_changed?
      SettingType.find(setting_type_id_change[1]).role_type != 'none'
    else
      false
    end
  end

  # @return [Boolean]
  def private_beta_registration_complete?
    !!private_beta_registration_complete
  end

  # @return [Boolean]
  def registration_complete_any
    !!private_beta_registration_complete || !!registration_complete
  end

  # @return [Datetime]
  def registered_at
    events.where(name: 'user_registration').first&.time # :first returns private_beta or public_beta if that is the only one
  end

  # @return [Array<Integer, nil>]
  def module_ttc
    if Rails.application.cms?
      Training::Module.ordered.reject(&:draft?).map(&:name).map { |mod| module_time_to_completion[mod] }
    else
      TrainingModule.published.map(&:name).map { |mod| module_time_to_completion[mod] }
    end
  end

  def redact!
    skip_reconfirmation!
    update!(first_name: 'Redacted',
            last_name: 'User',
            email: "redacted_user#{id}@example.com",
            closed_at: Time.zone.now,
            password: 'redacteduser')

    notes.update_all(body: nil)
  end

  def local_authority_text
    if local_authority.nil? || local_authority.eql?('local authority')
      'Multiple'
    else
      local_authority
    end
  end

private

  # @overload data_attributes
  # @see ToCsv#data_attributes
  #   @return [Hash] override
  def data_attributes
    DASHBOARD_ATTRS.map { |field| { field => send(field) } }.reduce(&:merge)
  end

  # @return [SettingType, nil]
  def setting
    @setting ||= SettingType.find(setting_type_id) if setting_type_id
  end

  # @return [Ahoy::Event::ActiveRecord_AssociationRelation]
  def password_changed_events
    events.where(name: 'user_password_change')
  end
end
