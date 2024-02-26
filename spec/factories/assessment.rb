FactoryBot.define do
  factory :assessment do
    association :user, :registered

    training_module { 'alpha' }
    started_at { Time.zone.now }

    trait :failed do
      passed { false }
      score { 0.0 }
      completed_at { Time.zone.now }
    end

    trait :passed do
      passed { true }
      score { 100.0 }
      completed_at { Time.zone.now }
    end
  end
end
