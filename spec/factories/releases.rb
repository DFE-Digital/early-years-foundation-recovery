FactoryBot.define do
  factory :release do
    name { 'alpha' }
    time { Time.zone.now }
  end
end
