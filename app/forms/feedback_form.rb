class FeedbackForm < BaseForm

  attr_accessor :user, :question, :answer

  validates :user, :question, :answer, presence: true

  def save
    return false unless valid?

    UserAnswer.create(user: user, question: question, answer: answer)
  end
end