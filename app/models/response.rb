#
# Persisted answers to CMS Questions
#
class Response < ApplicationRecord
  include ToCsv

  belongs_to :user

  validates :answers, presence: true

  scope :unarchived, -> { where(archived: false) }

  delegate :to_partial_path, :legend, to: :question

  # @return [Training::Module]
  def mod
    Training::Module.by_name(training_module)
  end

  # @return [Training::Question]
  def question
    mod.page_by_name(question_name)
  end

  # Disable if already answered unless confidence check
  # @return [Array<Training::Answer::Option>]
  def options
    if question.confidence_question?
      question.options(checked: answers)
    else
      question.options(checked: answers, disabled: responded?)
    end
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
