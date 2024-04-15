class FeedbackController < ApplicationController
  helper_method :content,
                :mod,
                :current_user_response,
                :feedback_complete?

  def index; end

  def show
    if question_name.eql? 'thank-you'
      feedback_cookie(:completed)
      track_feedback_complete
      render :thank_you
    end
  end

  def update
    if save_response!
      feedback_cookie(:started)
      track_feedback_start
      redirect
    else
      render :show, status: :unprocessable_entity
    end
  end

  # @see feedback#index
  # @return [Boolean]
  def feedback_complete?
    if current_user.guest?
      cookies[:course_feedback_completed].present?
    else
      current_user.completed_course_feedback?
    end
  end

private

  def redirect
    if content.last_feedback?
      redirect_to feedback_path('thank-you')
    elsif skip_next_question?
      if content.next_item.last_feedback?
        redirect_to feedback_path('thank-you')
      else
        redirect_to feedback_path(content.next_item.next_item.name)
      end
    else
      redirect_to feedback_path(content.next_item.name)
    end
  end

  # @return [Boolean]
  def skip_next_question?
    current_user.skip_question?(content.next_item)
  end

  # @return [Boolean]
  def save_response!
    current_user_response.update(
      answers: user_answers,
      correct: true,
      text_input: response_params[:text_input],
    )
  end

  # @return [Course]
  def mod
    Course.config
  end

  # @return [Training::Question]
  def content
    mod.page_by_name(question_name)
  end

  # @return [User, Guest, nil]
  def current_user
    super || guest
  end

  # @param question [Training::Question] default: current question
  # @return [Response]
  def current_user_response(question = content)
    @current_user_response ||= current_user.response_for_shared(question, mod)
  end

  # @return [String]
  def question_name
    params[:id]
  end

  # OPTIMIZE: duplicated from ResponsesController
  def response_params
    params.require(:response).permit!
  end

  # OPTIMIZE: duplicated from ResponsesController
  def user_answers
    Array(response_params[:answers]).compact_blank.map(&:to_i)
  end

  # @param state [Symbol, String]
  # @return [Hash]
  def feedback_cookie(state)
    cookies["course_feedback_#{state}"] = { value: current_user.visit_token }
  end

  def track_feedback_start
    track('feedback_start') if feedback_start_untracked?
  end

  def track_feedback_complete
    track('feedback_complete') if feedback_complete_untracked?
  end

  def feedback_start_untracked?
    untracked?('feedback_start', training_module_id: mod.name)
  end

  def feedback_complete_untracked?
    untracked?('feedback_complete', training_module_id: mod.name)
  end
end
