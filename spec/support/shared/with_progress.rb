RSpec.shared_context 'with progress' do
  let(:user) { create(:user, :registered) }

  let(:tracker) { Ahoy::Tracker.new(user: user, controller: 'training/pages') }

  let(:alpha) { Training::Module.by_name(:alpha) }
  let(:bravo) { Training::Module.by_name(:bravo) }
  let(:charlie) { Training::Module.by_name(:charlie) }
  let(:delta) { Training::Module.by_name(:delta) }

  let(:published_mods) { Training::Module.ordered.reject(&:draft?) }

  # @param mod [Training::Module]
  def start_module(mod)
    view_pages_upto(mod, 'sub_module_intro')
    module_start_event(mod)
  end

  # @param mod [Training::Module]
  def start_first_topic(mod)
    view_pages_upto(mod, 'topic_intro')
  end

  # @param mod [Training::Module]
  def start_second_submodule(mod)
    view_pages_upto(mod, 'sub_module_intro', 2)
  end

  # @param mod [Training::Module]
  def view_summary_intro(mod)
    view_pages_upto(mod, 'summary_intro')
  end

  # @param mod [Training::Module]
  def start_confidence_check(mod)
    view_pages_upto(mod, 'confidence_questionnaire')
  end

  # @param mod [Training::Module]
  def start_end_of_module_feedback_intro(mod)
    view_pages_upto(mod, 'opinion_intro')
  end

  # @param mod [Training::Module]
  def start_end_of_module_feedback_form(mod)
    view_pages_upto(mod, 'feedback')
  end

  # @param mod [Training::Module]
  def start_summative_assessment(mod)
    view_pages_upto(mod, 'summative_questionnaire')
  end

  # @param mod [Training::Module]
  def view_pages_upto_formative_question(mod, count = 1)
    view_pages_upto(mod, 'formative_questionnaire', count)
  end

  # @param mod [Training::Module]
  def view_certificate_page(mod)
    view_pages_upto(mod, 'certificate')
  end

  # @param mod [Training::Module]
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
  # @param mod [Training::Module]
  def module_start_event(mod)
    tracker.track('module_start', training_module_id: mod.name)
    calculate_ttc
  end

  # create a fake complete event
  # @param mod [Training::Module]
  def module_complete_event(mod)
    tracker.track('module_complete', training_module_id: mod.name)
    calculate_ttc
  end

  # @param mod_name [String]
  # @param page_name [String]
  # @return [true] create a fake page view event
  def view_module_page_event(mod_name, page_name)
    mod = Training::Module.by_name(mod_name)
    content = mod.page_by_name(page_name)

    puts "tracking #{mod.name}: #{content.name}" if ENV['VERBOSE'].present?

    tracker.track('module_content_page', {
      id: page_name,
      action: 'show',
      controller: 'training/pages',
      training_module_id: mod_name,
      type: content.page_type,
    })
  end

private

  def calculate_ttc
    CalculateModuleState.new(user: user).call
  end

  # Visit every page upto the nth instance of the given type
  # @param mod [Training::Module]
  def view_pages_upto(mod, type, count = 1)
    module_start_event(mod)

    counter = 0
    mod.content.map do |entry|
      view_module_page_event(mod.name, entry.name)
      counter += 1 if entry.page_type.eql?(type)
      break if counter.eql?(count)
    end
  end
end
