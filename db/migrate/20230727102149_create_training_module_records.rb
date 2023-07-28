class CreateTrainingModuleRecords < ActiveRecord::Migration[7.0]
  def change
    create_table :training_module_records do |t|
      t.integer :module_id, null: false
      t.string :name, null: false
      t.timestamps
    end
    add_index :training_module_records, :name, unique: true
  end
end
