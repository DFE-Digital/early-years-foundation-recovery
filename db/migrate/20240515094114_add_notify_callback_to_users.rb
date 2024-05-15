class AddNotifyCallbackToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :notify_callback, :jsonb
  end
end
