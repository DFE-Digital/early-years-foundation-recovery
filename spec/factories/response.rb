FactoryBot.define do
  factory :response do
    user
    training_module { 'alpha' }
    question_name { '1-1-4-1' }
    answers { [(1..5).to_a.sample] }

    trait :correct do
      correct { true }
    end

    trait :incorrect do
      correct { false }
    end

    trait :summative do
      schema {
        [
          "1-1-4",
          "summative_questionnaire",
          "Question - Select from following",
          {
            "correct": [2, 3],
            "options": [
              {"id": 1, "label": "Wrong answer 1"},
              {"id": 2, "label": "Correct answer 1"},
              {"id": 3, "label": "Correct answer 2"},
              {"id": 4, "label": "Wrong answer 2"}
            ],
            "incorrect": [1, 4]
          }
        ]
       }
    end
  end
end
