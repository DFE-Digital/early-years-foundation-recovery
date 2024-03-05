class Guest < Dry::Struct
  attribute :visit_id, Types::Strict::Integer

  def guest?
    true
  end

  # @param content [Training::Question]
  # @return [Response]
  def response_for_shared(content, _)
    Response.find_or_initialize_by(
      question_name: content.name,
      guest_visit: visit_id,
    )
  end

  # @return [Boolean]
  def completed_main_feedback?
    Response.where(guest_visit: visit_id).main_feedback.any?
  end
end
