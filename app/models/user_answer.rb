class UserAnswer < ApplicationRecord
  include ToCsv

  extend ActiveHash::Associations::ActiveRecordExtensions

  belongs_to :user

  serialize :answer, Array

  # Need to use IS as `where.not(archive: true)` always returns nil
  scope :not_archived, -> { where 'user_answers.archived IS NOT true' }

  # @return [Questionnaire]
  def questionnaire
    @questionnaire ||= Questionnaire.find_by!(training_module: self.module, name: name)
  end

  #
  # Make [UserAnswer] quack like [Response] for post-CMS migration
  # ----------------------------------------------------------------------------

  # @see Training::ResponsesController
  scope :cms_response, -> { where(questionnaire_id: 0) }

  scope :summative, -> { where(assessments_type: 'summative_assessment') }

  validates :answer, presence: true

  # @return [String]
  delegate :to_partial_path, to: :question

  # @return [String]
  delegate :legend, to: :question

  # @return [Array<Integer>]
  def answers
    answer
  end

  # @return [Training::Question]
  def question
    Training::Module.by_name(self.module).page_by_name(name)
  end

  # @return [Boolean]
  def responded?
    answer.any?
  end

  # @return [Boolean]
  def correct?
    question.confidence_question? || question.correct_answers.eql?(answers)
  end

  # [Array<Training::Answer::Option>]
  def options
    if question.confidence_question?
      question.options(checked: answers)
    else
      question.options(checked: answers, disabled: responded?)
    end
  end

  # @return [String]
  def selected_answers
    options.select(&:checked?).map(&:label).to_sentence
  end

  # @return [String]
  def banner_title
    correct? ? "That's right" : "That's not quite right"
  end

  # @return [String]
  def banner_style
    correct? ? 'govuk-notification-banner--success' : ''
  end

  # @return [String]
  def summary
    correct? ? question.success_message : question.failure_message
  end
end
