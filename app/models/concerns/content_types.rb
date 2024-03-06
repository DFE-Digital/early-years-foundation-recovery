# Content page_types ordered by appearance
#
module ContentTypes
  # @return [Boolean]
  def interruption_page?
    page_type.eql?('interruption_page')
  end

  # ============================================================================
  # TRAINING SECTIONS
  # ============================================================================

  # @return [Boolean]
  def submodule_intro?
    page_type.eql?('sub_module_intro')
  end

  # @return [Boolean]
  def topic_intro?
    page_type.eql?('topic_intro')
  end

  # @return [Boolean]
  def is_question?
    page_type.match?(/formative|summative|confidence|feedback/)
  end

  # @return [Boolean]
  def opinion_question?
    page_type.match?(/confidence|feedback/)
  end

  # @return [Boolean]
  def factual_question?
    page_type.match?(/formative|summative/)
  end

  # @return [Boolean]
  def text_page?
    page_type.eql?('text_page')
  end

  # @return [Boolean]
  def video_page?
    page_type.eql?('video_page')
  end

  # @return [Boolean]
  def formative_question?
    page_type.eql?('formative_questionnaire')
  end

  # ============================================================================
  # FINAL SECTION
  # ============================================================================

  # @return [Boolean]
  def summary_intro?
    page_type.eql?('summary_intro')
  end

  # @return [Boolean]
  def recap_page?
    page_type.eql?('recap_page')
  end

  # @return [Boolean]
  def assessment_intro?
    page_type.eql?('assessment_intro')
  end

  # @return [Boolean]
  def summative_question?
    page_type.eql?('summative_questionnaire')
  end

  # @return [Boolean]
  def assessment_results?
    page_type.eql?('assessment_results')
  end

  # @return [Boolean]
  def confidence_intro?
    page_type.eql?('confidence_intro')
  end

  # @return [Boolean]
  def confidence_question?
    page_type.eql?('confidence_questionnaire')
  end

  # @return [Boolean]
  def opinion_intro?
    page_type.eql?('opinion_intro')
  # def confidence_outro?
  #   page_type.eql?('confidence_outro')
  end

  # @return [Boolean]
  def one_off_question?
    always_show_question.eql?(false)
  end

  # @return [Boolean]
  def feedback_question?
    page_type.eql?('feedback')
  end

  # @return [Boolean]
  def thankyou?
    page_type.eql?('thankyou')
  end

  # @return [Boolean]
  def certificate?
    page_type.eql?('certificate')
  end
end
