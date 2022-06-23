class AddSettingTypeToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :setting_type, :string
    add_column :users, :setting_type_other, :string
  end
end
