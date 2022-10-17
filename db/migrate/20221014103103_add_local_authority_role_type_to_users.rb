class AddLocalAuthorityRoleTypeToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :local_authority, :string
    add_column :users, :role_type, :string
    add_column :users, :role_type_other, :string
  end
end
