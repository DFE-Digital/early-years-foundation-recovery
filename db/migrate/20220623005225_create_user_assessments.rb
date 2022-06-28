class CreateUserAssessments < ActiveRecord::Migration[7.0]
  def up
    create_table :user_assessments do |t|
      t.references :user, null: false, foreign_key: true
      t.string :score
      t.string :status # passed | failed
      t.string :module
      t.string :assessments_type
      t.boolean :archived
      t.datetime :completed # date time module completed not sure if we need this
      t.index %i[score status]
      t.timestamps
    end
  end

  def down
    drop_table :user_assessments
  end
end
