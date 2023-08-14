class CreatePreviouslyPublishedModules < ActiveRecord::Migration[7.0]
  def change
    create_table :previously_published_modules do |t|
      t.integer :module_position, null: false
      t.string :name, null: false
      t.datetime :first_published_at, null: false
      t.timestamps
    end
    add_index :previously_published_modules, :name, unique: true
    add_index :previously_published_modules, :module_position, unique: true
  end
end
