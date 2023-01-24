class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :timeoutable, :trackable, :recoverable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable,
         :validatable, :rememberable, :confirmable, :lockable, :timeoutable

  has_many :user_answers
  has_many :user_assessments
  has_many :visits, class_name: 'Ahoy::Visit'
  has_many :events, class_name: 'Ahoy::Event'
  has_many :notes

  scope :registered, -> { where(registration_complete: true) }
  scope :not_registered, -> { where(registration_complete: nil) }

  validates :first_name, :last_name, :setting_type_id,
            presence: true,
            if: proc { |u| u.registration_complete }
  validates :role_type, presence: true, if: proc { |u| u.role_type_required? }
  validates :setting_type_id,
            inclusion: { in: SettingType.valid_setting_types },
            if: proc { |u| u.registration_complete }

  validates :terms_and_conditions_agreed_at, presence: true, allow_nil: false, on: :create

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

  def course_started?
    !module_time_to_completion.empty?
  end

  def setting_name
    setting_type_id == 'other' ? setting_type_other : setting_type
  end

  def role
    role_type == 'other' ? role_type_other : role_type
  end

  def childminder?
    setting_type_id == 'other' ? false : setting.role_type.eql?('childminder')
  end

  def role_type_required?
    return false unless setting_type_id
    return false unless registration_complete?
    return true if setting_type_id == 'other'
    return false unless SettingType.valid_setting_types.include?(setting_type_id)
    return true if new_setting_type_role_required?

    setting.role_type != 'none'
  end

  def new_setting_type_role_required?
    if setting_type_id_changed?
      SettingType.find(setting_type_id_change[1]).role_type != 'none'
    else
      false
    end
  end

  def private_beta_registration_complete?
    !!private_beta_registration_complete
  end

private

  def setting
    @setting ||= SettingType.find(setting_type_id) if setting_type_id
  end

  # @return [Ahoy::Event::ActiveRecord_AssociationRelation]
  def password_changed_events
    events.where(name: 'user_password_change')
  end
end
