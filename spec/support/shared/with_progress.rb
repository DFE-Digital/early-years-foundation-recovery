RSpec.shared_context 'with progress' do
  let(:user) { create(:user, :registered) }
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
    view_pages_before(mod, 'confidence_questionnaire')
  end

  def start_summative_assessment(mod)
    view_pages_before(mod, 'summative_questionnaire')
  end

  def fail_summative_assessment(mod)
    create(:user_assessment, user_id: user.id, module: mod.name)
  end

  def view_pages_before_formative_questionnaire(mod)
    view_pages_before(mod, 'formative_questionnaire')
  end

  # @return [true] create a fake event log item
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

  def complete_summative_assessment_incorrect
    3.times do
      check 'Wrong answer 1'
      check 'Wrong answer 2'
      click_on 'Save and continue'
    end
    choose 'Wrong answer 1'
    click_on 'Finish test'
  end

  def complete_summative_assessment_correct
    3.times do
      check 'Correct answer 1'
      check 'Correct answer 2'
      click_on 'Save and continue'
    end
    choose 'Correct answer 1'
    click_on 'Finish test'
  end

  def complete_formative_assessment_correct
    choose 'Correct answer 1'
    4.times { click_on 'Next' }
    check 'Correct answer 1'
    check 'Correct answer 2'
    2.times { click_on 'Next' }
  end

  def complete_formative_assessment_incorrect
    choose 'Wrong answer 1'
    4.times { click_on 'Next' }
    check 'Wrong answer 1'
    2.times { click_on 'Next' }
  end

  def complete_module(mod)
    # Create 'module_content_page' events
    view_pages_before(mod, 'thankyou')
    # Resultsa in a 300s ttc
    travel_to 5.minutes.from_now
    # Visit thankyou page to create 'module_complete' event
    visit "/modules/#{mod.name}/content-pages/#{mod.last_page.name}"
  end

private

  # Visit every page before the nth instance of the given type
  def view_pages_before(mod, type, count = 1)
    visit "/modules/#{mod.name}/content-pages/intro" # 'module_start'

    counter = 0
    mod.module_items.map do |item|
      view_module_page_event(mod.name, item.name)
      counter += 1 if item.type.eql?(type)
      break if counter.eql?(count)
    end
  end
end
