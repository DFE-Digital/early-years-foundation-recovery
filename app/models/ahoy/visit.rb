class Ahoy::Visit < ApplicationRecord
  include ToCsv

  self.table_name = 'ahoy_visits'

  has_many :events, class_name: 'Ahoy::Event'
  belongs_to :user, optional: true

  scope :dashboard, -> { where(started_at: Time.zone.now.beginning_of_month..Time.zone.now) }
end
