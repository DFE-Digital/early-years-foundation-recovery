class AddSettingTypeIdToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :setting_type_id, :string
  end
end
