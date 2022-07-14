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

  # Visit every page before the given page type
  #
  def view_pages_before(mod, type)
    mod.module_items.map do |item|
      view_module_page_event(mod.name, item.name)
      break if item.type == type
    end
  end
end
