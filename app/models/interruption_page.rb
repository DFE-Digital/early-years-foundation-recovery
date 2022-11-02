class InterruptionPage
  include ActiveModel::Validations
  include ActiveModel::Model
  
  validates :heading, :body, presence: true

  # @return [String]
  def self.heading
    I18n.t('interruption_page.heading')
  end

  # @return [String]
  def self.body
    I18n.t('interruption_page.body')
  end
end