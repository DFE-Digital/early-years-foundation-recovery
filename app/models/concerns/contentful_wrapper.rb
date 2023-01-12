module ContentfulWrapper
  CMS_CONTENT = ContentfulRails.configuration.contentful_options[:modules]

  # @return [Boolean]
  def contentful?
    training_module.match?(Regexp.union(CMS_CONTENT))
  end

  # @return [Training::Page]
  def page_decorator
    @page_decorator ||= Training::Page.find_by(module_id: training_module, slug: name).first
  end

  # @return [Training::Question, Training::Confidence]
  def question_decorator
    @question_decorator ||=
      if confidence?
        Training::Confidence.find_by(module_id: training_module, slug: name).first
      else
        Training::Question.find_by(module_id: training_module, slug: name).first
      end
  end
end
