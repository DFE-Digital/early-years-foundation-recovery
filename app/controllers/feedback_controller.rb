class FeedbackController < ApplicationController
  helper_method :content,
                :mod,
                :current_user_response

  def index; end

  def show
    if content_name.eql? 'thank-you'
      track_feedback_complete
      render :thank_you
    end
  end

  def update
    if research_participation_updated?
      if save_response!
        flash[:success] = 'Your details have been updated'
        redirect_to user_path
      else
        render :show, status: :unprocessable_entity
      end

    elsif save_response!
      feedback_cookie
      track_feedback_start
      redirect_to feedback_path(helpers.next_page.name)
    else
      render :show, status: :unprocessable_entity
    end
  end

private

  # @return [Boolean]
  def research_participation_updated?
    current_user_response.question.skippable? && current_user_response.persisted?
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

  # @return [Training::Question, Training::Page]
  def content
    mod.page_by_name(content_name)
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
  def content_name
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

  # @return [Hash]
  def feedback_cookie
    cookies[:course_feedback] = { value: current_user.visit_token }
  end

  # @return [Boolean, nil]
  def track_feedback_start
    track('feedback_start') if untracked?('feedback_start')
  end

  # @return [Boolean, nil]
  def track_feedback_complete
    track('feedback_complete') if untracked?('feedback_complete')
  end

  # @param key [String]
  # @param params [Hash]
  # @return [Boolean]
  def untracked?(key)
    if current_user.guest?
      Event.where(visit_id: current_visit, name: key).empty?
    else
      Event.where(user_id: current_user, name: key).empty?
    end
  end
end
