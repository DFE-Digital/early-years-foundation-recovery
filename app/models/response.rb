class Response < ApplicationRecord
  belongs_to :user

  validates :answers, presence: true

  delegate :pagination,
           :body, :parent, :correct_answers, :assessments_type, :assessment_fail,
           :formative?, :summative?, :confidence?, :first_confidence?, :first_assessment?, :last_assessment?, :multi_select?,
           :next_button_text, to: :question

  scope :unarchived, -> { where(archive: false) }

  def mod
    @mod ||= Training::Module.by_name(training_module)
  end

  def question
    @question ||= mod.page_by_name(question_name)
  end

  # Disable if already answered unless confidence check
  def options
    if confidence?
      question.options(checked: answers)
    else
      question.options(checked: answers, disabled: responded?)
    end
  end

  # @return [Boolean]
  def can_respond?
    confidence? || !responded?
  end

  # RENAME Controls disabled
  #
  # @return [Boolean]
  def responded?
    answers.any?
  end

  # @return [Boolean]
  def correct?
    confidence? || correct_answers.eql?(answers)
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

    if multi_select?
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
