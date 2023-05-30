class Note < ApplicationRecord
  belongs_to :user

  encrypts :body

  def logged_at
    created_at.to_date.strftime('%-d %B %Y')
  end

  # @return [Boolean]
  def filled?
    body.to_s.strip != ''
  end
end
