class Visit < ApplicationRecord
  include ToCsv

  has_many :events
  belongs_to :user, optional: true

  scope :month_old, -> { where(started_at: 4.weeks.ago.beginning_of_day..4.weeks.ago.end_of_day) }
  scope :within_4_weeks, -> { where(started_at: 4.weeks.ago.end_of_day..Time.zone.now) }
  scope :week_old, -> { where(started_at: 7.days.ago.beginning_of_day..7.days.ago.end_of_day) }
  scope :within_1_week, -> { where(started_at: 7.days.ago.end_of_day..Time.zone.now) }
  scope :dashboard, -> { where(started_at: Time.zone.now.beginning_of_month..Time.zone.now) }
end
