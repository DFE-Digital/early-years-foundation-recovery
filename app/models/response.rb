#
# Submitted response to Training::Question
#
class Response < ApplicationRecord
  include ToCsv

  belongs_to :user
  belongs_to :assessment, optional: true

  validates :answers, presence: true

  scope :incorrect, -> { where(correct: false) }
  scope :correct, -> { where(correct: true) }

  scope :ungraded, -> { where(graded: false) }
  scope :graded, -> { where(graded: true) }

  scope :formative, -> { where(question_type: 'formative') }
  scope :summative, -> { where(question_type: 'summative') }
  scope :confidence, -> { where(question_type: 'confidence') }
  scope :feedback, -> { where(question_type: 'feedback') }

  delegate :to_partial_path, :legend, to: :question

  # @return [Training::Module]
  def mod
    Training::Module.by_name(training_module)
  end

  # @return [Training::Question]
  def question
    mod.page_by_name(question_name)
  end

  # @return [Array<Training::Answer::Option>]
  def options
    if question.formative_question? || assessment&.graded?
      question.options(checked: answers, disabled: responded?)
    else
      question.options(checked: answers)
    end
  end

  # @return [Boolean]
  def archived?
    archived
  end

  # @return [Boolean]
  def responded?
    answers.any?
  end

  # @return [Boolean]
  def correct?
    question.confidence_question? || question.correct_answers.eql?(answers)
  end

  # @return [Boolean]
  def revised?
    correct && !correct?
  end

  ########################
  # Decorators           #
  ########################

  # @return [String]
  def banner_title
    correct? ? "That's right" : "That's not quite right"
  end

  # @return [String, nil]
  def banner_style
    'govuk-notification-banner--success' if correct?
  end

  # @return [String]
  def summary
    correct? ? question.success_message : question.failure_message
  end

  # @return [String]
  def selected_answers
    options.select(&:checked?).map(&:label).to_sentence
  end
end
