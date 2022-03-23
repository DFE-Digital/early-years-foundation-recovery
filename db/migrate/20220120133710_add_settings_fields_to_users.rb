class AddSettingsFieldsToUsers < ActiveRecord::Migration[7.0]
  def change
    change_table :users, bulk: true do |t|
      t.string :postcode
      t.string :ofsted_number
    end
  end
end
