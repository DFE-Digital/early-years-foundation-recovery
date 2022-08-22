RSpec.shared_context 'with events' do
  let(:module_name) { alpha.name }
  
  let(:user) { create(:user, :completed) }
  let(:user1) { create(:user, :completed) }
  let(:user2) { create(:user, :completed) }
  
  let(:events) do
    Ahoy::Event.where(user_id: user.id).where_properties(training_module_id: module_name)
  end

  def create_event(user, name, time, training_module, id=nil)
    Ahoy::Event.new(user: user, name: name, time: time,
      properties: {training_module_id: training_module, id: id},
      visit: Ahoy::Visit.new()).save!
  end
end