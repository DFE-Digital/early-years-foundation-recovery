class AddLocalAuthorityToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :local_authority, :string
  end
end
