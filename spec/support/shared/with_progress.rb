RSpec.shared_context 'with progress' do
  let(:user) { create(:user, :registered) }
  let(:tracker) { Ahoy::Tracker.new(user: user, controller: 'content_pages') }

  let(:alpha) { TrainingModule.find_by(name: 'alpha') }
  let(:bravo) { TrainingModule.find_by(name: 'bravo') }
  let(:charlie) { TrainingModule.find_by(name: 'charlie') }
  let(:delta) { TrainingModule.find_by(name: 'delta') }

  def start_module(mod)
    view_pages_upto(mod, 'module_intro')
  end

  def start_first_submodule(mod)
    view_pages_upto(mod, 'sub_module_intro')
  end

  def start_first_topic(mod)
    view_pages_upto(mod, 'text_page')
  end

  def start_second_submodule(mod)
    view_pages_upto(mod, 'sub_module_intro', 2)
  end

  def view_summary_intro(mod)
    view_pages_upto(mod, 'summary_intro')
  end

  def start_confidence_check(mod)
    view_pages_upto(mod, 'confidence_questionnaire')
  end

  def start_summative_assessment(mod)
    view_pages_upto(mod, 'summative_questionnaire')
  end

  def fail_summative_assessment(mod)
    create(:user_assessment, user_id: user.id, module: mod.name)
  end

  def view_pages_upto_formative_question(mod)
    view_pages_upto(mod, 'formative_questionnaire')
  end

  def view_certificate_page(mod)
    view_pages_upto(mod, 'certificate')
  end

  # @param mod [TrainingModule]
  # @param duration [ActiveSupport::Duration]
  def complete_module(mod, duration = nil)
    view_pages_upto(mod, 'certificate')
    travel_to duration.from_now unless duration.nil?
    module_complete_event(mod)
  end

  #
  # Create events --------------------------------------------------------------
  #

  # create a fake start event
  def module_start_event(mod)
    tracker.track('module_start', training_module_id: mod.name)
    calculate_ttc
  end

  # create a fake complete event
  def module_complete_event(mod)
    tracker.track('module_complete', training_module_id: mod.name)
    calculate_ttc
  end

  # @return [true] create a fake page view event
  def view_module_page_event(module_name, page_name)
    item = ModuleItem.find_by(training_module: module_name, name: page_name)

    tracker.track('module_content_page', {
      id: page_name,
      action: 'show',
      controller: 'content_pages',
      training_module_id: module_name,
      type: item.type,
    })
  end

private

  def calculate_ttc
    CalculateModuleState.new(user: user).call
  end

  # Visit every page upto the nth instance of the given type
  def view_pages_upto(mod, type, count = 1)
    module_start_event(mod)

    counter = 0
    mod.module_items.map do |item|
      view_module_page_event(mod.name, item.name)
      counter += 1 if item.type.eql?(type)
      break if counter.eql?(count)
    end
  end
end
