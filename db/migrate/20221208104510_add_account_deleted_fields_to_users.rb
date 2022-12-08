class AddAccountDeletedFieldsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :account_deleted_at, :datetime
    add_column :users, :deleted_reason, :string
    add_column :users, :deleted_reason_other, :string
  end
end
