class MigrateAssessments
  def call
    ActiveRecord::Base.transaction do
      puts 'Truncate assessments'
      ActiveRecord::Base.connection.execute('TRUNCATE assessments RESTART IDENTITY CASCADE')

      puts 'Migrating user_assessments to assessments'
      UserAssessment.all.find_each do |record|
        # define
        params = {
          user_id: record.user_id,               # int key
          training_module: record.module,        # string key
          score: record.score,                   # float
          passed: record.status.eql?('passed'),  # bool
          started_at: record.user_answers.order(:created_at).first.created_at, # datetime
          completed_at: record.created_at,        # datetime
        }

        # persist
        Assessment.create!(**params).save!
      end

      raise ActiveRecord::Rollback if ENV['test']
      puts 'Migrated user_assessments to assessments'
    end
  end
end
