class TrainingModule < YamlBase
  set_filename ENV.fetch('TRAINING_MODULES', 'training-modules')

  # Override basic behaviour so that root key is stored as name
  def self.load_file
    raw_data.map { |name, values| values.merge(name: name) }
  end

  # @return [Integer]
  def topic_count
    ModuleItem.topics(name).group_by { |m| [m.submodule_name, m.topic_name] }.count
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

  # @param type [String]
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

  # @return [ModuleItem] viewing this page determines if the module is "started"
  def first_content_page
    module_intros.first.next_item
  end
end
