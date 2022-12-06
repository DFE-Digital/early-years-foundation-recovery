RSpec.shared_context 'with user assessment' do
  def create_user_assessment(user, score, status, module_name, assessments_type, completed)
    UserAssessment.new(user_id: user.id, score: score,
                       status: status,
                       module: module_name,
                       assessments_type: assessments_type,
                       completed: completed).save!
  end
end
