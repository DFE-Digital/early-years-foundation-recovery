class AddAccountDeletedAtToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :account_deleted_at, :datetime
  end
end
