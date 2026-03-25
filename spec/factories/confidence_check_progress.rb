FactoryBot.define do
  factory :confidence_check_progress do
    user
    module_name { 'alpha' }
    check_type { 'pre' }
    started_at { Time.zone.now }
    completed_at { nil }
    skipped_at { nil }

    trait :pre do
      check_type { 'pre' }
    end

    trait :post do
      check_type { 'post' }
    end

    trait :completed do
      completed_at { Time.zone.now }
    end

    trait :skipped do
      started_at { nil }
      skipped_at { Time.zone.now }
    end
  end
end
