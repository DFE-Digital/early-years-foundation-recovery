FactoryBot.define do
  factory :user_assessment do
    score { 0 }
    assessments_type { 'summative_assessment' }

    trait :passed do
      status { 'passed' }
    end

    trait :failed do
      status { 'failed' }
    end
  end
end
