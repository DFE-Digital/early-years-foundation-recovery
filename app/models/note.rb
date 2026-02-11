class Note < ApplicationRecord
  belongs_to :user

  encrypts :body

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
