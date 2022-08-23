FactoryBot.define do
  factory :user_answer do
    user
    question { Faker::Lorem.word }
    answer { [Faker::Lorem.word] }
  end
end
