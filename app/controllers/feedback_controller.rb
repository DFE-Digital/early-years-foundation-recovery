class FeedbackController < ApplicationController
  before_action :track_feedback_start, only: :show
  after_action :track_feedback_complete, only: :update
  helper_method :content,
                :mod,
                :current_user_response,
                :feedback_exists?

  def show; end

  def index; end

  def update
    if save_response!
      redirect
    else
      render 'feedback/show', status: :unprocessable_entity
    end
  end

  # @return [Boolean]
  def feedback_exists?
    if current_user.guest?
      cookies[:feedback_complete].present?
    else
      current_user.started_main_feedback?
    end
  end

private

  def redirect
    if content.eql?(mod.pages.last)
      redirect_to feedback_thank_you_path
    elsif content.next_item.skippable? && (current_user.guest? || current_user.response_for_shared(content.next_item, mod).responded?)
      redirect_to feedback_thank_you_path
      feedback_complete_cookie if current_user.guest?
    else
      redirect_to feedback_path(content.next_item.name)
    end
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

  # @return [Response]
  def current_user_response(question = content)
    @current_user_response ||= current_user.response_for_shared(question, mod)
  end

  # @return [Hash]
  def feedback_complete_cookie
    cookies[:feedback_complete] = {
      value: current_user.visit.visit_token,
    }
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

  def track_feedback_start
    if content.first_feedback? && feedback_start_untracked?
      track('feedback_start')
    end
  end

  def track_feedback_complete
    if content.last_feedback? && feedback_complete_untracked?
      track('feedback_complete')
    end
  end

  def feedback_start_untracked?
    untracked?('feedback_start', training_module_id: mod.name)
  end

  def feedback_complete_untracked?
    untracked?('feedback_complete', training_module_id: mod.name)
  end
end
