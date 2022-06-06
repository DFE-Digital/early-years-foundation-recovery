class TrainingModule < YamlBase
  set_filename ENV.fetch('TRAINING_MODULES', 'training-modules')

  # Override basic behaviour so that root key is stored as name
  def self.load_file
    raw_data.map { |name, values| values.merge(name: name) }
  end

  # @return [Array<TrainingModule>]
  def self.by_state(user:, state:)
    case state.to_sym
    when :active    then all.select { |mod| user.active?(mod) }
    when :upcoming  then all.select { |mod| user.upcoming?(mod) }
    when :completed then all.select { |mod| user.completed?(mod) }
    else
      raise 'TrainingModule#by_state can query either :active, :upcoming or :completed modules'
    end
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
  def overview_page
    module_items_by_type('module_intro').first
  end

  # @return [ModuleItem]
  def first_content_page
    overview_page.next_item
  end
end
