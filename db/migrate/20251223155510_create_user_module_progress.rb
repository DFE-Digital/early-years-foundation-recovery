class CreateUserModuleProgress < ActiveRecord::Migration[7.2]
  def change
    create_table :user_module_progress do |t|
      t.references :user, foreign_key: true, null: false
      t.string :module_name, null: false
      t.datetime :started_at
      t.datetime :completed_at
      t.jsonb :visited_pages, default: {}
      t.string :last_page
      t.timestamps
    end

    add_index :user_module_progress, %i[user_id module_name], unique: true
  end
end
