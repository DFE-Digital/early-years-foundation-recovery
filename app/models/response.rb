class Response < ApplicationRecord
  belongs_to :user

  validates :answers, presence: true

  # @see Training::Question
  delegate :pagination,
           :body, :parent, :correct_answers, :assessments_type, :assessment_fail,
           :formative_question?, :summative_question?, :confidence_question?,
           :first_confidence?, :first_assessment?, :last_assessment?,
           :multi_select?,
           :next_button_text, to: :question

  scope :unarchived, -> { where(archive: false) }

  # TODO: memo needed?
  # @return [Training::Module]
  def mod
    @mod ||= Training::Module.by_name(training_module)
  end

  # TODO: memo needed?
  # @return [?]
  def question
    @question ||= mod.page_by_name(question_name)
  end

  # Disable if already answered unless confidence check
  # @return [?]
  def options
    if confidence_question?
      question.options(checked: answers)
    else
      question.options(checked: answers, disabled: responded?)
    end
  end

  # @return [Boolean]
  def can_respond?
    confidence_question? || !responded?
  end

  # RENAME Controls disabled
  #
  # @return [Boolean]
  def responded?
    answers.any?
  end

  # @return [Boolean]
  def correct?
    confidence_question? || correct_answers.eql?(answers)
  end

          # @return [Boolean]
          def show_assessment?
            formative_question? && responded?
          end

          # @return [Boolean]
          def assess?
            summative_question? && last_assessment?
          end

  # @return [String]
  def banner_title
    correct? ? "That's right" : "That's not quite right"
  end

  # @return [String]
  def summary
    correct? ? question.assessment_succeed : question.assessment_fail
  end

  # @return [String] powered by JSON not type
  def to_partial_path
    if multi_select?
      formative_question? ? 'training/responses/learning_check_boxes' : 'training/responses/check_boxes'
    else
      formative_question? ? 'training/responses/learning_radio_buttons' : 'training/responses/radio_buttons'
    end
  end

  # @return [Array<String>]
  def user_response
    options.select { |option| Array(answer).include?(option.id) }.map(&:label)
  end
end
