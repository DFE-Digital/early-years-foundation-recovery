class UserAssessment < ApplicationRecord
  include ToCsv

  has_many :user_answers
  # Need to use IS as `where.not(archive: true)` always returns nil
  scope :not_archived, -> { where 'user_answers.archived IS NOT true' }
end
