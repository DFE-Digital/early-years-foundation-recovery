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

  def postcode=(input)
    super UKPostcode.parse(input.to_s).to_s
  end

  def ofsted_number=(input)
    super input.to_s.strip.upcase
  end

  #
  # My learning --------------------------------------------------
  #

  # @return [Array<TrainingModule>] training modules with no incomplete dependency
  def available_modules
    training_modules_by_state(:upcoming).reject { |mod| !available?(mod) }
  end

  # @return [Array<TrainingModule>]
  def upcoming_modules
    training_modules_by_state(:upcoming).reject { |mod| available?(mod) }.take(3)
  end

  # TODO: use a dedicated event for module completion
  #
  # @return [Array<Array>] Tabular data of completed training module
  def completed_modules
    training_modules_by_state(:completed).map do |mod|
      final_page = mod.module_items.last.name
      completed_at = training_module_events(mod).where_properties(id: final_page).first.time

      [mod, completed_at]
    end
  end

  # @return [Array<TrainingModule>] training modules by state
  def training_modules_by_state(state)
    TrainingModule.by_state(user: self, state: state)
  end

  # @return [Boolean] module content has been viewed
  def started?(mod)
    return false if mod.draft?

    training_module_events(mod).where_properties(id: mod.first_content_page.name).present?
  end

  # TODO: this state is currently true if the last page was viewed
  #
  # @return [Boolean]
  def completed?(mod)
    return false if mod.draft?

    training_module_events(mod).where_properties(id: mod.module_items.last.name).present?
  end

  # @return [Boolean]
  def active?(mod)
    started?(mod) && !completed?(mod)
  end

  # @return [Boolean]
  def upcoming?(mod)
    !started?(mod) && !completed?(mod)
  end

  # @return [Boolean]
  def available?(mod)
    dependent = TrainingModule.find_by(name: mod.depends_on)
    dependent ? completed?(mod) : false
  end

  # @return [String] training module 'milestone' content id
  def last_page_for(mod)
    page = training_module_events(mod).last
    page.properties['id'] if page.present?
  end

private

  #
  # Events --------------------------------------------------
  #

  # @return [Ahoy::Event::ActiveRecord_AssociationRelation]
  def password_changed_events
    events.where(name: 'password_changed')
  end

  # @return [Ahoy::Event::ActiveRecord_AssociationRelation]
  def training_module_events(mod)
    events.where_properties(training_module_id: mod.name)
  end
end
