class DropUserAssessmentsTable < ActiveRecord::Migration[7.1]
  def up
    drop_table :user_assessments
  end

  def down
    create_table :user_assessments do |t|
      t.references :user, null: false, foreign_key: true
      t.string :score
      t.string :status
      t.string :module
      t.string :assessments_type
      t.boolean :archived
      t.datetime :completed
      t.index %i[score status]
      t.timestamps
    end
  end
end
