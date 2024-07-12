# Form processing for training and feedback
#
module Answering
  extend ActiveSupport::Concern

private

  # @return [Boolean]
  def multiple_choice?
    params[:response][:answers].is_a?(Array)
  end

  # @return [Boolean]
  def correct?
    content.opinion_question? ? true : content.correct_answers.eql?(response_answers)
  end

  # @return [ActionController::Parameters]
  def response_params
    if multiple_choice?
      params.require(:response).permit(:text_input, answers: [])
    else
      params.require(:response).permit(:text_input, :answers)
    end
  end

  # @return [String]
  def response_text_input
    response_params[:text_input]
  end

  # @return [Array<Integer>]
  def response_answers
    Array(response_params[:answers]).compact_blank.map(&:to_i)
  end

  # @return [Boolean]
  def save_response!
    current_user_response.update(
      answers: response_answers,
      correct: correct?,
      text_input: response_text_input,
    )
  end
end
