class TrainingModule < YamlBase
  set_filename ENV.fetch('TRAINING_MODULES', 'training-modules')

  # Override basic behaviour so that root key is stored as name
  def self.load_file
    raw_data.map { |name, values| values.merge(name: name) }
  end

  # @return [Boolean]
  def draft?
    attributes.fetch(:draft, false)
  end

  # @return [Array<ModuleItem>]
  def module_items
    ModuleItem.where(training_module: name).to_a
  end

  # @return [Array<ModuleItem>]
  def module_items_by_type(type)
    ModuleItem.where(training_module: name, type: type).to_a
  end

  # @return [ModuleItem]
  def module_intro
    module_items_by_type('module_intro').first
  end

  # @return [ModuleItem] viewing this page determines if the module is "started"
  def first_content_page
    module_intro.next_item
  end
end
