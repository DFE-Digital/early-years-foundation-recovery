FactoryBot.define do
  factory :module_release do
    release
    module_position { 1 }
    name { 'alpha' }
    first_published_at { Time.zone.now }
  end
end
