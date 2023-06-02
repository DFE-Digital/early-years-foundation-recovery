FactoryBot.define do
  factory :user_answer do
    user
    question { Faker::Lorem.word }
    answer { [Faker::Lorem.word] }

    trait :correct do
      correct { true }
    end

    trait :incorrect do
      correct { false }
    end

    trait :summative do
      assessments_type { 'summative_assessment' }
    end
  end
end
