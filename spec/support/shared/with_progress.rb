RSpec.shared_context 'with progress' do
  let(:user) { create(:user) }
  let(:tracker) { Ahoy::Tracker.new(user: user, controller: 'content_pages') }

  # @return [true] create a fake event log item
  def view_module_page_event(module_name, page_name)
    tracker.track('page_view', {
      id: page_name,
      action: 'show',
      controller: 'content_pages',
      training_module_id: module_name,
    })
  end
end
