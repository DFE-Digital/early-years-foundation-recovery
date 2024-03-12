class Assessment < ApplicationRecord
  include ToCsv

  belongs_to :user
  has_many :responses, -> { where(question_type: 'summative') }

  scope :incomplete, -> { where(completed_at: nil) }
  scope :complete, -> { where.not(completed_at: nil) }

  scope :passed, -> { where(passed: true) }
  scope :failed, -> { where(passed: false) }

  # @return [Boolean]
  def passed?
    passed
  end

  # @return [Boolean]
  def graded?
    score.present?
  end
end
