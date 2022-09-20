class BackfillModuleState < CalculateModuleState
private

  FINAL_PAGE_NAMES = {
    'child-development-and-the-eyfs' => '1-3-3',
    'brain-development-and-how-children-learn' => '2-3-4',
    'personal-social-and-emotional-development' => '3-4-4',
  }.freeze

  def module_names
    FINAL_PAGE_NAMES.keys
  end

  def mod_event(training_module, event_name, page_name)
    user.events.where(name: event_name).where_properties(training_module_id: training_module, id: page_name).first
  end

  def mod_complete(training_module)
    mod_event(training_module, 'module_content_page', FINAL_PAGE_NAMES[training_module])
  end

  def mod_start(training_module)
    mod_event(training_module, 'module_content_page', 'intro')
  end
end