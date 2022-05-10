class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :timeoutable, :trackable, :recoverable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable,
         :validatable, :rememberable, :confirmable, :lockable, :timeoutable

  has_many :user_answers
  has_many :visits, class_name: 'Ahoy::Visit'
  has_many :events, class_name: 'Ahoy::Event'

  def last_page_for(training_module:)
    events.where_properties(training_module_id: training_module.name).last&.properties
  end

  def started?(training_module:)
    last_page_for(training_module:).present?
  end

  def name
    [first_name, last_name].compact.join(' ')
  end

  def email_to_confirm
    pending_reconfirmation? ? unconfirmed_email : email
  end
end
