class FeedbackController < ApplicationController
  helper_method :previous_path, :next_path, :content, :feedback_exists?

  # @return [nil]
  def show
    redirect_to next_path unless always_show_question?
  end

  # @return [nil]
  def index; end

  # @return [nil]
  def update
    return if invalid_answer?

    res = response_exists? ? update_response : create_response

    if res.save && res.errors[:text_input].empty?
      redirect_to next_path
    else
      flash[:error] = res.errors.full_messages.to_sentence
      redirect_to current_feedback_path
    end
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
    return feedback_thank_you_path if params[:id].to_i == questions.count

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
  def guest?
    current_user.nil?
  end

  # @return [Boolean]
  def invalid_answer?
    if answer.blank? || answer.all?(&:blank?) || (content.free_text? && text_input.blank?)
      flash[:error] = 'Please answer the question'
      redirect_to current_feedback_path and return true
    else
      false
    end
  end

  # @return [Response]
  def create_response
    Response.new(
      user_id: current_user ? current_user.id : nil,
      answers: answer_content,
      question_name: content.name,
      text_input: text_input,
      guest_visit: guest? ? current_visit.visitor_token : nil,
    )
  end

  # @return [Response]
  def update_response
    existing_response.update!(
      answers: answer_content,
      text_input: text_input,
    )
    existing_response
  end

  # @return [Boolean]
  def response_exists?
    existing_response.present?
  end

  # @return [Response]
  def existing_response
    Response.find_by(
      guest_visit: guest? ? current_visit.visitor_token : nil,
      user_id: current_user&.id,
      question_name: content.name,
    )
  end

  # @return [Boolean]
  def show_question?
    always_show_question? && (!current_user.nil? || !response_exists?)
  end

  # @return [Boolean]
  def always_show_question?
    !content.always_show_question.eql?(false)
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
    @answer ||= if content.free_text?
                  params[:answers]
                else
                  Array.wrap(params[:answers])
                end
  end

  # @return [Array<String>]
  def answer_content
    @answer_content ||= begin
      return [] if answer.blank?
      return answer if content.free_text?

      answer.reject(&:blank?).map { |a| answer_wording(a) }.flatten
    end
  end

  def text_input
    @text_input ||= params[:text_input]
  end
end
