class FeedbackController < ApplicationController
  include Answering

  before_action :research_participation, only: :show

  helper_method :content,
                :mod,
                :current_user_response

  def index
    track('feedback_intro')
  end

  def show
    if content_name.eql? 'thank-you'
      track_feedback_complete
      render :thank_you
    end
  end

  def update
    if current_user.profile_updated? && save_response!
      flash[:success] = 'Your details have been updated'
      redirect_to user_path
    elsif save_response!
      feedback_cookie
      track_feedback_start
      redirect_to feedback_path(helpers.next_page.name)
    else
      render :show, status: :unprocessable_content
    end
  end

private

  # @note
  #   associate the user research participation question to the course form
  #   if answered during a training module
  #
  def research_participation
    response = current_user.user_research_response
    if content.skippable? && response.present? && !response.training_module.eql?('course')
      response.update!(training_module: 'course')
    end
  end

  # @return [Course]
  def mod
    Course.config
  end

  # @return [Training::Question, Training::Page]
  def content
    mod.page_by_name(content_name)
  end

  # @return [User, Guest]
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

  # @return [Hash]
  def feedback_cookie
    cookies[:course_feedback] = {
      value: current_user.visit_token,
      expires: 2.days.from_now,
    }
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
  # @return [Boolean]
  def untracked?(key)
    if current_user.guest?
      Event.where(visit_id: current_visit, name: key).empty?
    else
      Event.where(user_id: current_user, name: key).empty?
    end
  end
end
