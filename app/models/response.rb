class Response < ApplicationRecord
  belongs_to :user

  validates :answer, presence: true

  delegate :pagination,
           :body, :parent, :correct_answer, :assessments_type, :assessment_fail,
           :formative?, :summative?, :confidence?, :first_confidence?, :first_assessment?, :last_assessment?,
           :next_button_text, to: :question

  scope :unarchived, -> { where(archive: false) }

  def mod
    @mod ||= Training::Module.by_name(training_module)
  end

  def question
    @question ||= mod.page_by_name(question_name)
  end

  def options
    return question.options if confidence?

    question.options.map do |option|
      option.disabled = responded?
      option
    end
  end

  def responded?
    answer.present?
  end

  def correct?
    return true if confidence?

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
    return 'training/responses/radio_buttons' if confidence?

    if Array(correct_answer).size > 1
      'training/responses/check_boxes'
    else
      'training/responses/radio_buttons'
    end
  end

  # @return [Array<String>]
  def user_response
    options.select { |option| Array(answer).include?(option.id) }.map(&:label)
  end
end
