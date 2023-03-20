class CreateResponse < ActiveRecord::Migration[7.0]
  def change
    create_table :responses do |t|
      t.references :user, null: false, foreign_key: true
      t.string :training_module
      t.string :question_name
      t.jsonb :answer
      t.boolean :archive
      t.timestamps
    end
  end
end
