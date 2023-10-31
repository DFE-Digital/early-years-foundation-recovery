class AddIdTokenToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :id_token, :string
    add_index :users, :id_token, unique: true
  end
end
