RSpec.shared_context 'with completed course' do
  let(:user) { create(:user, :registered) }

  let(:tracker) { Ahoy::Tracker.new(user: user, controller: 'training/pages') }

  let(:alpha) { Training::Module.by_name(:alpha) }
  let(:bravo) { Training::Module.by_name(:bravo) }
  let(:charlie) { Training::Module.by_name(:charlie) }

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
