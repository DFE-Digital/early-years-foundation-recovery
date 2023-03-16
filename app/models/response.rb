class Response < ApplicationRecord
  belongs_to :user

  validates :answer, presence: true

  delegate :pagination, :body, :parent, :correct_answer, :assessments_type, :formative?, :summative?, :last_assessment?, to: :question

  def mod
    @mod ||= Training::Module.by_name(training_module)
  end

  def question
    @question ||= mod.page_by_name(question_name)
  end

  def options
    question.options.map do |option|
      option.disabled = responded?
      option
    end
  end

  def responded?
    answer.present?
  end

  def correct?
    correct_answer == answer
  end

  def banner_title
    correct? ? "That's right" : "That's not quite right"
  end

  def summary
    correct? ? question.assessment_succeed : question.assessment_fail
  end

  def show_assessment?
    formative? && responded?
  end

  def assess?
    summative? && last_assessment?
  end

  # @return [String]
  def to_partial_path
    if Array(correct_answer).count > 1
      "training/responses/check_boxes"
    else
      "training/responses/radio_buttons"
    end
  end
end
