# This migration introduces a new table called TrainingModuleRecords. We are adding
# this table to track the newly released training modules and their relevant details.
# Each new release handled by the hook controller checks if it contains any modules not
# currently in the table. Whenever a new training module is released, a record will be 
# created in this table to store information such as module id, name and release date
#
# The TrainingModuleRecords table will provide us with a centralised and structured
# way to keep track of our training module releases and the dates on which they were
# first published. This information will be useful for communicating new releases to
# users and potentially for analytical purposes.
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
