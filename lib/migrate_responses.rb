class MigrateResponses
  def call
    ActiveRecord::Base.transaction do
      puts 'Truncate responses'
      ActiveRecord::Base.connection.execute('TRUNCATE responses RESTART IDENTITY CASCADE')

      puts 'Migrating user_answers to responses'
      UserAnswer.all.find_each do |record|
        # define
        params = {
          user_id: record.user_id,                  # int key
          assessment_id: record.user_assessment_id, # int key
          training_module: record.module,           # string key
          question_name: record.name,               # string key
          question_type: record.assessments_type,   # string
          answers: record.answer,                   # array
          correct: record.correct,                  # bool
          created_at: record.created_at,            # datetime
          updated_at: record.updated_at,            # datetime
        }

        # persist
        Response.create!(**params).save! # (validate: false)
      end
    end
    puts 'Migrated user_answers to responses'
  end
end
