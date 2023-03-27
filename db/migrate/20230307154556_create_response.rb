class CreateResponse < ActiveRecord::Migration[7.0]
  def change
    create_table :responses do |t|
      t.references :user, null: false, foreign_key: true
      t.string :training_module, null: false
      t.string :question_name, null: false
      t.jsonb :answers, default: []
      t.boolean :archive, default: false
      t.timestamps
    end
  end
end
