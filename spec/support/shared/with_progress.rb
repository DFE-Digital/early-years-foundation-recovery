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

  # Visit the first page in first submodule
  #
  def start_submodule(mod)
    view_pages_before(mod, 'sub_module_intro')
  end
  
  # Visit the first topic page in first submodule
  #
  def start_topic(mod)
    view_pages_before(mod, 'text_page')
  end

  # Visit the second submodule page
  #
  def start_second_submodule(mod)
    view_pages_before(mod, 'sub_module_intro', 2)
  end

  # Visit every page before the first summative assessment
  #
  def view_pages_before_summative_assessment(mod)
    view_pages_before(mod, 'summative_assessment')
  end

  # Visit every page before the first formative assessment
  #
  def view_pages_before_formative_assessment(mod)
    view_pages_before(mod, 'formative_assessment')
  end

  # Visit every page before the first confidence check
  #
  def view_pages_before_confidence_check(mod)
    view_pages_before(mod, 'confidence_check')
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

private

  # Visit every page before the given instance of the given page type
  #
  def view_pages_before(mod, type, instances=1)
    i = 0
    mod.module_items.map do |item|
      view_module_page_event(mod.name, item.name)
      i+=1 if item.type == type
      break if i == instances
    end
  end
end
