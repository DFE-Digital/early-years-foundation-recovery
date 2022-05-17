class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :timeoutable, :trackable, :recoverable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable,
         :validatable, :rememberable, :confirmable, :lockable, :timeoutable

  has_many :user_answers
  has_many :visits, class_name: 'Ahoy::Visit'
  has_many :events, class_name: 'Ahoy::Event'

  validates_with OfstedValidator
  validates :first_name, :last_name, presence: true, if: Proc.new {|u| u.registration_complete }

  def name
    [first_name, last_name].compact.join(' ')
  end

  def email_to_confirm
    pending_reconfirmation? ? unconfirmed_email : email
  end

  def password_last_changed
    password_changed_events&.time&.to_date&.to_formatted_s(:rfc822)
  end

  def password_changed_events
    events.where(name: 'password_changed')&.last
  end
end
