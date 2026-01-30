RSpec.shared_context 'with events' do
  let(:user) { create(:user, :registered) }
  let(:user_one) { create(:user, :registered) }
  let(:user_two) { create(:user, :registered) }

  let(:events) do
    Event.where(user_id: user.id).where_properties(training_module_id: mod.name)
  end

  def create_event(user, name, time, training_module, id = nil)
    Event.new(user: user, name: name, time: time,
              properties: { training_module_id: training_module, id: id },
              visit: Visit.new).save!

    # Also create/update UserModuleProgress
    progress = UserModuleProgress.find_or_initialize_by(user: user, module_name: training_module)
    progress.visited_pages ||= {}

    case name
    when 'module_start'
      progress.started_at ||= time
    when 'module_complete'
      progress.started_at ||= time
      progress.completed_at ||= time
    when 'module_content_page', 'page_view'
      progress.started_at ||= time
      progress.visited_pages[id] ||= time&.iso8601 if id.present?
      progress.last_page = id if id.present?
    end

    progress.save!
  end
end
