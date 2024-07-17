class DropUserAnswersTable < ActiveRecord::Migration[7.1]
  def up
    drop_table :user_answers
  end

  def down
    create_table :user_answers do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :questionnaire_id, null: false, index: true
      t.string :question
      t.string :answer
      t.boolean :correct
      t.boolean :archived
      t.index %i[questionnaire_id user_id]
      t.timestamps
      t.string :module
      t.string :name
      t.string :assessments_type
      t.references :user_assessment, null: true, foreign_key: true
      t.string :state
    end
  end
end
