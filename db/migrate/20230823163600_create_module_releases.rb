class CreateModuleReleases < ActiveRecord::Migration[7.0]
  def change
    create_table :module_releases do |t|
      t.references :release, null: false, foreign_key: true
      t.integer :module_position, null: false
      t.string :name, null: false
      t.datetime :first_published_at, null: false
      t.timestamps
    end
    add_index :module_releases, :name, unique: true
    add_index :module_releases, :module_position, unique: true
  end
end
