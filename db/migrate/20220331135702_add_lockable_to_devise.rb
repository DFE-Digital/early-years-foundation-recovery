class AddLockableToDevise < ActiveRecord::Migration[7.0]
  def change
    change_table :users, bulk: true do |t|
      t.integer :failed_attempts, default: 0, null: false
      t.datetime :locked_at
      
      t.string :unlock_token
      t.index :unlock_token
    end
  end
end
