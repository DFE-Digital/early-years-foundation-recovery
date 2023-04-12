class UserAssessment < ApplicationRecord
  include ToCsv

  has_many :user_answers
end
