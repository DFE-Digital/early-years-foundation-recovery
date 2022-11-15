class AddRoleTypeToUsers < ActiveRecord::Migration[7.0]
  def change
    change_table :users, bulk: true do |t|
      t.string :role_type
      t.string :role_type_other
    end
  end
end
