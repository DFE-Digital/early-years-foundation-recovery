class UserAssessment < ApplicationRecord
  include ToCsv

  has_many :user_answers
  scope :summative, -> { where(assessments_type: 'summative_assessment') }
  scope :passes, -> { where(status: 'passed') }
  scope :fails, -> { where(status: 'failed') }

  def passed?
    status == 'passed'
  end
end
