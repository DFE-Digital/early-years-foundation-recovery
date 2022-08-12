RSpec.shared_context 'with foo' do
  include_context 'with progress'
  include_context 'with user'

  let(:module_name) { alpha.name }
  
  let(:events) do
    Ahoy::Event.where(user_id: user.id).where_properties(training_module_id: module_name)
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
end