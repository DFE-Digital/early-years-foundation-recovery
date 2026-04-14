FactoryBot.define do
  factory :question, class: 'Training::Question' do
    id { '49Z7xDMPfGAnIY8jzyD4ia' }
    name { '1-2-1-1' }
    page_type { 'formative' }
    answers { [['Correct answer 1', true], ['Wrong answer 1']] }
    parent_id { '6EczqUOpieKis8imYPc6mG' }
    published_at { Time.zone.parse('2023-01-01 00:00:00 UTC') }

    initialize_with do
      fields = {
        'id' => id,
        'name' => name,
        'page_type' => page_type,
        'answers' => answers,
        'parent_id' => parent_id,
        'published_at' => published_at,
      }
      Training::Question.new(fields)
    end
  end
end
