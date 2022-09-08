class User::Note < ApplicationRecord
  belongs_to :user

  validates :body, length: { maximum: 20000 }

  def logged_at 
    created_at.to_date.strftime('%-d %B %Y')
  end
  
  # @return [String]
  def debug_summary
    <<~SUMMARY
      id: User note #{id}
      name: #{training_module}
      path: #{name}
      errors: #{errors.count}
    SUMMARY
  end
end
