FactoryBot.define do
  factory :response do
    user
    training_module { 'alpha' }
    question_name { '1-1-4-1' }
    question_type { 'formative' }
    answers { [(1..5).to_a.sample] }
  end
end
