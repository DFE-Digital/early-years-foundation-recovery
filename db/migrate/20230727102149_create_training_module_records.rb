class CreateTrainingModuleRecords < ActiveRecord::Migration[7.0]
  def change
    create_table :training_module_records do |t|
      t.integer :module_id, null: false
      t.string :name, null: false
      t.timestamps
    end
  end
end
