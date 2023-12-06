RSpec.shared_context 'with module releases' do
  before do
    create_module_release(1, 'alpha', 2.days.ago)
    create_module_release(2, 'bravo', 3.days.ago)
    create_module_release(3, 'charlie', 2.minutes.ago)
  end

  def create_module_release(id, name, first_published_at)
    create(:release, id: id)
    create(:module_release, release_id: id, module_position: id, name: name, first_published_at: first_published_at)
  end
end
