FactoryBot.define do
  factory :user_answer do
    user
    questionnaire_data { QuestionnaireData.find_by!(name: :test, training_module: :test) }
    question { Faker::Lorem.word }
    answer { [Faker::Lorem.word] }
  end
end
