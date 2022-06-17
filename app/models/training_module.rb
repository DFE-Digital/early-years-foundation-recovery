class TrainingModule < YamlBase
  set_filename ENV.fetch('TRAINING_MODULES', 'training-modules')

  # Override basic behaviour so that root key is stored as name
  def self.load_file
    raw_data.map { |name, values| values.merge(name: name) }
  end

  # @return [Integer]
  def topic_count
    items_by_topic.except(nil).count
  end

  # predicates ---------------------------------

  # @return [Boolean]
  def draft?
    attributes.fetch(:draft, false)
  end

  # collections -------------------------

  # @return [Array<ModuleItem>]
  def module_items
    ModuleItem.where(training_module: name).to_a
  end

  # @example
  #   {
  #     "1" => [1-1-1, 1-1-2],
  #     "2" => [1-2-1, 1-2-2],
  #   }
  #
  # @return [{String=>Array<ModuleItem>}]
  def items_by_submodule
    module_items.group_by(&:submodule_name)
  end

  # @example
  #   {
  #     ["1", "1"] => [1-1-1-1a, 1-1-1-1b],
  #     ["1", "2"] => [1-1-2-1, 1-1-2-2],
  #   }
  #
  # @return [{Array<String>=>Array<ModuleItem>}]
  def items_by_topic
    module_items.group_by { |m| [m.submodule_name, m.topic_name] if m.topic_name }
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

  # @return [Array<ModuleItem>]
  def module_intros
    module_items_by_type('module_intro')
  end

  # sequence ---------------------------------

  # @return [ModuleItem]
  def interuption_page
    module_intros.first.next_item
  end

  # Viewing this page determines if the module is "started"
  # @return [ModuleItem]
  def first_content_page
    interuption_page.next_item
  end
end
