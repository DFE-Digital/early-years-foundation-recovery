class Response < ApplicationRecord
  belongs_to :user

  validates_presence_of :answer

  delegate :pagination, :body, :parent, :correct_answer, to: :question

  def mod
    @mod ||= Training::Module.by_name(training_module)
  end

  def question
    @question ||= mod.page_by_name(question_name)
  end

  def options
    question.options.map{|option| option.disabled=responded?;option}
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
    fields = multi_select? ? :check_boxes : :radio_buttons
    "responses/#{page_type}_#{fields}"
  end

end