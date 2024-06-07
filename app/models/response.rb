#
# Submitted response to Training::Question
#
class Response < ApplicationRecord
  include ToCsv

  belongs_to :user, optional: true
  belongs_to :assessment, optional: true
  belongs_to :visit, optional: true

  encrypts :text_input

  validates :training_module, presence: true
  validates :question_type, inclusion: { in: %w[formative summative confidence feedback] }
  validates :answers, presence: true, unless: -> { text_input_only? }

  scope :incorrect, -> { where(correct: false) }
  scope :correct, -> { where(correct: true) }

  scope :ungraded, -> { where(graded: false) }
  scope :graded, -> { where(graded: true) }

  scope :formative, -> { where(question_type: 'formative') }
  scope :summative, -> { where(question_type: 'summative') }
  scope :confidence, -> { where(question_type: 'confidence') }
  scope :feedback, -> { where(question_type: 'feedback') }
  scope :course_feedback, -> { feedback.where(training_module: 'course') }

  delegate :to_partial_path, :legend, to: :question

  # @return [Training::Module, Course]
  def mod
    if training_module.eql?('course')
      Course.config
    else
      Training::Module.by_name(training_module)
    end
  end

  # @return [Training::Question]
  def question
    mod.page_by_name(question_name)
  end

  # @return [Array<Training::Answer::Option>]
  def options
    if question.formative_question? || assessment&.graded?
      question.options(checked: answers, disabled: responded?)

    # the numeric value for "Or" could be all options plus one but "zero" is consistent
    elsif question.feedback_question? && !question.has_other? && question.has_or? && text_input.present?
      question.options(checked: [0])

    else
      question.options(checked: answers)
    end
  end

  # @return [Boolean]
  def checked_other?
    question.has_other? && answers.include?(question.options.last.id)
  end

  # @see Question#options
  # @return [Boolean]
  def checked_or?
    question.has_or? && answers.include?(0)
  end

  # Validate that an option is selected unless question only expects text.
  #
  # @return [Boolean]
  def text_input_only?
    question.only_text?
  end

  # @return [Boolean]
  def archived?
    archived
  end

  # @return [Boolean]
  def responded?
    answers.any? || text_input.present?
  end

  # @return [Boolean]
  def correct?
    question.opinion_question? || question.correct_answers.eql?(answers)
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
