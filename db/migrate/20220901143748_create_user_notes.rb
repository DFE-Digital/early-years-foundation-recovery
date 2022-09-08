class CreateUserNotes < ActiveRecord::Migration[7.0]
  def change
    create_table :user_notes do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.text :body
      t.string :training_module
      t.string :name

      t.timestamps
    end
  end
end
