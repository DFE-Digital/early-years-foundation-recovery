class Response < ApplicationRecord
  belongs_to :user

  validates :answer, presence: true

  delegate :pagination, :body, :parent, :correct_answer, :page_type, to: :question

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

  def formative?
    true
  end

  def confidence?
    false
  end

  def first_confidence?
    false
  end

  def first_assessment?
    false
  end

  # @return [String]
  def to_partial_path
    if correct_answer.count > 1
      "responses/#{page_type}_check_boxes"
    else
      "responses/#{page_type}_radio_buttons"
    end
  end
end
