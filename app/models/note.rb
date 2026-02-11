class Note < ApplicationRecord
  belongs_to :user

  encrypts :body

  validates :body, presence: true
  validates :training_module, presence: true
  validates :name, presence: true
  validates :user_id, uniqueness: { scope: [:training_module, :name], message: "already has a note for this page" }

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
