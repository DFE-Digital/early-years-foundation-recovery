#
# Calculate a user's time to complete a module using the difference in time
# between when they first viewed the first and last pages.
#
class BackfillModuleState < CalculateModuleState
private

  FINAL_PAGE_NAMES = {
    'child-development-and-the-eyfs' => '1-3-2-6',
    'brain-development-and-how-children-learn' => '2-3-3-5',
    'personal-social-and-emotional-development' => '3-4-3-7',
  }.freeze

  def module_names
    FINAL_PAGE_NAMES.keys
  end

  def mod_event(training_module, page_name)
    user.events
      .where(name: 'module_content_page')
      .where_properties(training_module_id: training_module, id: page_name)
      .first
  end

  def mod_complete(training_module)
    mod_event(training_module, FINAL_PAGE_NAMES[training_module])
  end

  def mod_start(training_module)
    mod_event(training_module, 'intro')
  end
end
