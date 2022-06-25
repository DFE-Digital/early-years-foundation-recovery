class AddSettingTypeToUsers < ActiveRecord::Migration[7.0]
  def change
    change_table :users, bulk: true do |t|
      t.string :setting_type
      t.string :setting_type_other
    end
  end
end
