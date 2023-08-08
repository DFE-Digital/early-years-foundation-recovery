FactoryBot.define do
  factory :user_answer do
    user
    question { Faker::Lorem.word }
    answer { [Faker::Lorem.word] }

    trait :questionnaire do
      questionnaire_id { 0 }
    end

    trait :correct do
      correct { true }
    end

    trait :incorrect do
      correct { false }
    end

    trait :summative do
      assessments_type { 'summative_assessment' }
    end

    trait :confidence do
      assessments_type { 'confidence_check' }
    end
  end
end
