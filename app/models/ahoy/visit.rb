class Ahoy::Visit < ApplicationRecord
  include ToCsv

  self.table_name = 'ahoy_visits'

  has_many :events, class_name: 'Ahoy::Event'
  belongs_to :user, optional: true

  scope :month_old, -> { where(started_at: 4.weeks.ago.beginning_of_day..4.weeks.ago.end_of_day) }
end
