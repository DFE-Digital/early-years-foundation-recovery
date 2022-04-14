class CreateUserAnswers < ActiveRecord::Migration[7.0]
  def change
    create_table :user_answers do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :questionnaire_id, null: false, index: true
      t.string :question
      t.string :answer
      t.boolean :correct
      t.boolean :archived
      t.index %i[questionnaire_id user_id]
      t.timestamps
    end
  end
end
