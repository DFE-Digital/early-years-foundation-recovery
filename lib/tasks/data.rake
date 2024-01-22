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
  task migrate_responses: :environment do
    require 'migrate_responses'
    MigrateResponses.new.call
  end

  desc 'Migrate user_assessments to assessments'
  task migrate_assessments: :environment do
    require 'migrate_assessments'
    MigrateAssessments.new.call
  end
end
