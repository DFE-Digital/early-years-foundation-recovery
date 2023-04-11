class UserAssessment < ApplicationRecord
  include ToCsv

  has_many :user_answers
  has_many :user_responses

  # Need to use IS as `where.not(archive: true)` always returns nil
  scope :not_archived, -> { where 'user_answers.archived IS NOT true' }
  scope :response_not_archived, -> { where 'user_responses.archive IS NOT true' }
end
