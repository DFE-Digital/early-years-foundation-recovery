class AddAccountDeletedFieldsToUsers < ActiveRecord::Migration[7.0]
  def change
    change_table :users, bulk: true do |t|
      t.datetime :account_deleted_at
      t.string :deleted_reason
      t.string :deleted_reason_other
    end
  end
end
