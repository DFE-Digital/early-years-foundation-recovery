class TrainingModule < YamlBase
  set_filename ENV.fetch('TRAINING_MODULES', 'training-modules')

  # Override basic behaviour so that root key is stored as name
  def self.load_file
    raw_data.map { |name, values| values.merge(name: name) }
  end

  # @return [Integer]
  def topic_count
    items_by_topic.count
  end

  # predicates ---------------------------------

  # @return [Boolean]
  def draft?
    attributes.fetch(:draft, false)
  end

  # @return [Boolean]
  def formative?
    @formative ||= ModuleItem.where_type(name, 'formative_assessment').any?
  end

  # @return [Boolean]
  def summative?
    @summative ||= ModuleItem.where_type(name, 'summative_assessment').any?
  end

  # collections -------------------------

  # @return [Array<Questionnaire>]
  def questionnaires
    Questionnaire.find_by!(training_module: name)
  rescue ActiveHash::RecordNotFound
    []
  end

  # @return [Array<ModuleItem>]
  def module_items
    @module_items ||= ModuleItem.where(training_module: name).to_a
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

  # @param type [String] text_page, youtube_page...
  # @return [Array<ModuleItem>]
  def module_items_by_type(type)
    ModuleItem.where_type(name, type)
  end

  # @param submodule_name [Integer, String]
  # @return [Array<ModuleItem>]
  def module_items_by_submodule(submodule_name)
    ModuleItem.where_submodule(name, submodule_name)
  end

  # sequence ---------------------------------

  # @return [ModuleItem]
  def interruption_page
    module_items.first
  end

  # @return [ModuleItem]
  def intro_page
    interruption_page.next_item
  end

  # Viewing this page determines if the module is "started"
  # @return [ModuleItem]
  def first_content_page
    intro_page.next_item.next_item # TODO: improve this (first page after submod intro)
  end

  # @return [ModuleItem]
  def assessment_page
    ModuleItem.where_type(name, 'formative_assessment').first
  end
end
