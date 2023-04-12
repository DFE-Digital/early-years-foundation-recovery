FactoryBot.define do
  factory :response do
    user
    training_module { 'alpha' }
    question_name { '1-1-4' }
    answer { (1..4).sample }
  end
end
