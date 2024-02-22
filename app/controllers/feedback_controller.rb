class FeedbackController < ApplicationController
  helper_method :previous_path, :next_path, :content, :is_checkbox?, :is_free_text?, :feedback_exists?

  # @return [nil]
  def show
    redirect_to next_path if skip_question?
  end

  # @return [nil]
  def index; end

  # @return [nil]
  def update
    return if invalid_answer? || other_blank?

    response_exists? ? update_response : create_response
    redirect_to next_path
  end

  # @return [String]
  def is_checkbox?
    content.response_type
  end

  # @return [Boolean]
  def is_free_text?
    content.answers.empty?
  end

  # @return [Boolean]
  def feedback_exists?
    return false if current_user.nil?

    Response.where(user_id: current_user.id).exists?
  end

  # @return [String] path to next feedback step
  def next_path
    return my_modules_path if action_name == 'thank_you'
    return feedback_path(1) if params[:id].nil?
    return thank_you_path if params[:id].to_i == questions.count

    feedback_path(params[:id].to_i + 1)
  end

  # @return [String] path to previous feedback step
  def previous_path
    return my_modules_path if params[:id].nil?
    return feedback_path(1) if params[:id] == '1'

    feedback_path(params[:id].to_i - 1)
  end

private

  # @return [Boolean]
  def invalid_answer?
    if answer.blank? || answer.all?(&:blank?)
      flash[:error] = 'Please answer the question'
      redirect_to current_feedback_path and return true
    else
      false
    end
  end

  # @return [Boolean]
  def other_blank?
    if answer_content.include?('Other') && text_input.blank?
      flash[:error] = 'Please specify'
      redirect_to current_feedback_path and return true
    else
      false
    end
  end

  # @return [Response]
  def create_response
    Response.create!(
      user_id: current_user ? current_user.id : nil,
      answers: answer_content,
      question_name: content.name,
      text_input: text_input,
    )
  end

  # @return [Response]
  def update_response
    Response.where(user_id: current_user.id, question_name: content.name).update(
      answers: answer_content,
      text_input: text_input,
    )
  end

  # @return [Boolean]
  def response_exists?
    return false if current_user.nil?

    Response.where(user_id: current_user.id, question_name: content.name).exists?
  end

  # @return [Boolean]
  def skip_question?
    return false unless skipped_questions.include?(content.name)

    true if current_user.nil?
  end

  # @return [Array<String>]
  def skipped_questions
    %w[main-feedback-6]
  end

  # @param answer [String]
  # @return [String]
  def answer_wording(answer)
    content.answers[answer.to_i - 1].first
  end

  # @return [Array<Hash>]
  def questions
    Course.config.feedback
  end

  # @return [String]
  def current_feedback_path
    feedback_path(params[:id])
  end

  # @return [Hash]
  def content
    @content ||= questions[params[:id].to_i - 1]
  end

  # @return [Array<String>]
  def answer
    @answer ||= if is_free_text?
                  params[:answers]
                else
                  Array.wrap(params[:answers])
                end
  end

  # @return [Array<String>]
  def answer_content
    @answer_content ||= begin
      return [] if answer.blank?
      return answer if is_free_text?

      answer.reject(&:blank?).map { |a| answer_wording(a) }.flatten
    end
  end

  def text_input
    @text_input ||= params[:answers_custom]
  end
end
