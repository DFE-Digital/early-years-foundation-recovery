RSpec.shared_context 'with progress' do
  let(:user) { create(:user) }
  let(:tracker) { Ahoy::Tracker.new(user: user, controller: 'content_pages') }

  let(:alpha) { TrainingModule.find_by(name: 'alpha') }
  let(:bravo) { TrainingModule.find_by(name: 'bravo') }
  let(:charlie) { TrainingModule.find_by(name: 'charlie') }
  let(:delta) { TrainingModule.find_by(name: 'delta') }

  # Visit every page in the module
  #
  def view_whole_module(mod)
    mod.module_items.map { |item| view_module_page_event(mod.name, item.name) }
  end

  # Visit the module intro page
  #
  def start_module(mod)
    view_pages_before(mod, 'module_intro')
  end

  def start_first_submodule(mod)
    view_pages_before(mod, 'sub_module_intro')
  end

  def start_first_topic(mod)
    view_pages_before(mod, 'text_page')
  end

  def start_second_submodule(mod)
    view_pages_before(mod, 'sub_module_intro', 2)
  end

  def start_confidence_check(mod)
    # view_pages_before(mod, 'confidence_intro')
    view_pages_before(mod, 'confidence_questionnaire')
  end

  def start_summative_assessment(mod)
    # view_pages_before(mod, 'assessment_intro')
    view_pages_before(mod, 'summative_questionnaire')
  end

  def view_pages_before_formative_questionnaire(mod)
    view_pages_before(mod, 'formative_questionnaire')
  end

  # @return [true] create a fake event log item
  def view_module_page_event(module_name, page_name)
    tracker.track('page_view', {
      id: page_name,
      action: 'show',
      controller: 'content_pages',
      training_module_id: module_name,
    })
  end

  # @return [true] create a fake event log item for a specific event key and controller
  def view_module_page_event_with_specified_key(module_name, page_name, track_key, controller_name)
    tracker.track(track_key, {
      id: page_name,
      action: 'show',
      controller: controller_name,
      training_module_id: module_name,
    })
  end

private

  # Visit every page before the given instance of the given page type
  #
  def view_pages_before(mod, type, count = 1)
    counter = 0
    mod.module_items.map do |item|
      view_module_page_event(mod.name, item.name)
      counter += 1 if item.type == type
      break if counter == count
    end
  end
end
