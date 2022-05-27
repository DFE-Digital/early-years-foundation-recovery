class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :timeoutable, :trackable, :recoverable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable,
         :validatable, :rememberable, :confirmable, :lockable, :timeoutable

  has_many :user_answers
  has_many :visits, class_name: 'Ahoy::Visit'
  has_many :events, class_name: 'Ahoy::Event'

  validates :first_name, :last_name, :postcode,
            presence: true,
            if: proc { |u| u.registration_complete }

  validates :password, password: true
  validates :postcode, postcode: true
  validates :ofsted_number, ofsted_number: true

  # @return [Array]
  def learning(state:)
    training_modules = TrainingModule.all

    case state
    when :started
      training_modules.select { |mod| started?(training_module: mod) }
    when :not_started
      training_modules.reject { |mod| started?(training_module: mod) }
    end
  end

  # @return [Hash<String>]
  def last_page_for(training_module:)
    events.where_properties(training_module_id: training_module.name).last&.properties
  end

  # @return [Boolean]
  def started?(training_module:)
    last_page_for(training_module:).present?
  end

  # @return [String]
  def name
    [first_name, last_name].compact.join(' ')
  end

  def email_to_confirm
    pending_reconfirmation? ? unconfirmed_email : email
  end

  def password_last_changed
    timestamp = password_changed_events&.time || created_at
    timestamp.to_date&.to_formatted_s(:rfc822)
  end

  def password_changed_events
    events.where(name: 'password_changed')&.last
  end

  def postcode=(input)
    super UKPostcode.parse(input.to_s).to_s
  end

  def ofsted_number=(input)
    super input.to_s.strip.upcase
  end
end
