class CreateAssessments < ActiveRecord::Migration[7.0]
  def change
    create_table :assessments do |t|
      t.references :user, null: false, foreign_key: true
      t.string :training_module, null: false
      t.float :score
      t.boolean :passed
      t.datetime :started_at
      t.datetime :completed_at

      t.index %i[score passed]
    end
  end
end
