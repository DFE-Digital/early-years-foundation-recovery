namespace :data do
  desc 'Run all migrations'
  task migrations: :environment do
    Rake.application.in_namespace(:data) do |namespace|
      namespace.tasks.each do |task|
        next if task.name == 'data:migrations'

        puts "Invoking #{task.name}"
        task.invoke
      end
    end
  end

  desc 'Migrate user answers to responses'
  task migrate_user_answers_to_responses: :environment do
    puts 'Truncate responses'
    ActiveRecord::Base.connection.execute('TRUNCATE responses RESTART IDENTITY CASCADE')
    puts 'Migrating user answers to responses'
    UserAnswer.all.find_each do |user_answer|
      response = Response.create!(
        user_id: user_answer.user_id,
        training_module: user_answer.module,
        question_name: user_answer.name,
        answers: user_answer.answer,
        correct: user_answer.correct,
        schema: user_answer.question.schema,
        user_assessment_id: user_answer.user_assessment_id,
      )
      response.save!(validate: false)
    end
    puts 'Migrated user answers to responses'
  end
end
