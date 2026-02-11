class Note < ApplicationRecord
  belongs_to :user

  encrypts :body

  validates :body, presence: true, allow_blank: false
  validates :training_module, presence: true, allow_blank: false
  validates :name, presence: true, allow_blank: false

  scope :filled, -> { where.not(body: [nil, Types::EMPTY_STRING]) }

  def logged_at
    updated_at.to_date.strftime('%-d %B %Y')
  end

  # @note blanks lines still counted
  # @return [Boolean]
  def filled?
    body.to_s.strip.present?
  end
end
