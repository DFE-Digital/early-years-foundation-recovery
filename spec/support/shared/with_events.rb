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
  end
end
