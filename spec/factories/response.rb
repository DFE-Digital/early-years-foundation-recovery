FactoryBot.define do
  factory :response do
    user
    training_module { 'alpha' }
    question_name { '1-1-4' }
    answers { [(1..5).to_a.sample] }
  end
end
