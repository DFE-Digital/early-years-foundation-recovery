class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :timeoutable, :trackable, :recoverable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable,
         :validatable, :rememberable, :confirmable, :lockable, :timeoutable

  has_many :user_answers
  has_many :visits, class_name: 'Ahoy::Visit'
  has_many :events, class_name: 'Ahoy::Event'

  validates :first_name, :last_name, :postcode, :setting_type,
            presence: true,
            if: proc { |u| u.registration_complete }

  validates :postcode, postcode: true
  validates :ofsted_number, ofsted_number: true

  def postcode=(input)
    super UKPostcode.parse(input.to_s).to_s
  end

  def ofsted_number=(input)
    super input.to_s.strip.upcase
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

  def training_module_completed_at(_mod)
    'Date completed: TBD'
  end

private

  # @return [Ahoy::Event::ActiveRecord_AssociationRelation]
  def password_changed_events
    events.where(name: 'password_changed')
  end
end
