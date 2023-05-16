class Note < ApplicationRecord
  belongs_to :user

  encrypts :body

  def logged_at
    created_at.to_date.strftime('%-d %B %Y')
  end

  def filled?
    !body.strip.empty?
  end
end
