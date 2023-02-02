class TrainingModule < YamlBase
  set_filename Rails.configuration.training_modules

  scope :published, -> { where(draft: nil) }

  # Override basic behaviour so that root key is stored as name
  def self.load_file
    raw_data.map { |name, values| values.merge(name: name) }
  end

  # @return [Integer]
  def topic_count
    items_by_topic.count
  end

  # @return [Integer]
  def submodule_count
    items_by_submodule.count
  end

  # predicates ---------------------------------

  # @return [Boolean]
  def published?
    !draft?
  end

  # @return [Boolean]
  def draft?
    attributes.fetch(:draft, false)
  end

  # collections -------------------------

  # @return [Array<Questionnaire>]
  def questionnaires
    module_items
      .select { |item| item.type.include?('questionnaire') }
      .map { |item| Questionnaire.find_by!(training_module: name, name: item.name) }
  end

  # @return [Array<ModuleItem>]
  def module_items
    @module_items ||= ModuleItem.where(training_module: name).to_a
  end

  # @return [Array<ModuleItem>] excludes certificate page
  def pages
    excluded_page_types = %w[certificate]
    @pages ||= ModuleItem.where(training_module: name).where.not(type: excluded_page_types).to_a
  end

  # @example
  #   {
  #     "1" => [1-1-1, 1-1-2],
  #     "2" => [1-2-1, 1-2-2],
  #   }
  #
  # @return [{String=>Array<ModuleItem>}]
  def items_by_submodule
    @items_by_submodule ||= module_items.group_by(&:submodule_name).except(nil)
  end

  # @example
  #   {
  #     ["1", "1"] => [1-1-1-1a, 1-1-1-1b],
  #     ["1", "2"] => [1-1-2-1, 1-1-2-2],
  #   }
  #
  # @return [{Array<String>=>Array<ModuleItem>}]
  def items_by_topic
    @items_by_topic ||= module_items.group_by { |m|
      [m.submodule_name, m.topic_name] if m.topic_name
    }.except(nil)
  end

  # @param type [String] text_page, video_page...
  # @return [Array<ModuleItem>]
  def module_items_by_type(type)
    ModuleItem.where_type(name, type)
  end

  # @param submodule_name [Integer, String]
  # @return [Array<ModuleItem>]
  def module_items_by_submodule(submodule_name)
    ModuleItem.where_submodule(name, submodule_name)
  end

  # @return [Array<ModuleItem>]
  def formative_questions
    module_items_by_type('formative_questionnaire')
  end

  # @return [Array<ModuleItem>]
  def summative_questions
    module_items_by_type('summative_questionnaire')
  end

  # @return [Array<ModuleItem>]
  def confidence_questions
    module_items_by_type('confidence_questionnaire')
  end

  # @return [Array<ModuleItem>]
  def video_pages
    module_items_by_type('video_page')
  end

  # sequence ---------------------------------

  # @return [ModuleItem]
  def interruption_page
    module_items.first
    # module_items_by_type('interruption_page').first
  end

  # Viewing this page determines if the module is "started"
  # @return [ModuleItem]
  def first_content_page
    module_items_by_type('sub_module_intro').first
  end

  # @return [ModuleItem]
  def summary_intro_page
    module_items_by_type('summary_intro').first
  end

  # @return [ModuleItem]
  def recap_page
    module_items_by_type('recap_page').first
  end

  # @return [ModuleItem]
  def assessment_intro_page
    module_items_by_type('assessment_intro').first
  end

  # @return [ModuleItem]
  def assessment_results_page
    module_items_by_type('assessment_results').first
  end

  # @return [ModuleItem]
  def confidence_intro_page
    module_items_by_type('confidence_intro').first
  end

  # @return [ModuleItem]
  def thankyou_page
    module_items_by_type('thankyou').first
  end

  # @return [ModuleItem] the last module item
  def certificate_page
    module_items_by_type('certificate').first
  end

  # decorations -------------------------

  # @return [ModuleItem]
  def last_page
    pages.last
  end

  def tab_label
    ['Module', id].join(' ')
  end

  def tab_anchor
    tab_label.parameterize
  end

  # @return [String]
  def card_title
    coming_soon = 'Coming soon - ' if draft?
    "#{coming_soon}Module #{id}: #{title}"
  end

  # @return [String]
  def card_anchor
    "#module-#{id}-#{title.downcase.parameterize}"
  end
end
