class FeedbackController < ApplicationController
  helper_method :content,
                :mod,
                :current_user_response

  def show; end

  def index; end

  def update
    if save_response!
      redirect_to feedback_path(content.next_item.name)
    else
      render 'feedback/show', status: :unprocessable_entity
    end
  end

private

  # @return [Boolean]
  def save_response!
    current_user_response.update(
      question_type: 'feedback',
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

  # @return [Response]
  def current_user_response
    @current_user_response ||= current_user.response_for_shared(content, mod)
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
end
