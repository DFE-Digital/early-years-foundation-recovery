class Guest < Dry::Struct
  # @!attribute [r] visit
  #   @return [Visit]
  attribute :visit, Types.Instance(Visit)

  # @return [Boolean]
  def guest?
    true
  end

  # @param content [Training::Question] feedback questions
  # @return [Response]
  def response_for_shared(content, _mod)
    responses.find_or_initialize_by(
      question_type: content.page_type,
      question_name: content.name,
      # training_module: nil,
      guest_visit: visit.id,
    )
  end

  # @return [Boolean]
  # def started_main_feedback?
  #   responses.any?
  # end

  # @return [Boolean]
  def completed_main_feedback?
    Course.config.pages.count.eql? responses.count
  end

private

  # @return [Response::ActiveRecord_Relation]
  def responses
    Response.main_feedback.where(guest_visit: visit.id)
  end
end
