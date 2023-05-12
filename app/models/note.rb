class Note < ApplicationRecord
  belongs_to :user

  encrypts :body

  def logged_at
    created_at.to_date.strftime('%-d %B %Y')
  end

  # @return [Boolean] true if the note is empty
  def present?
    !body.strip.empty?
  end
end
