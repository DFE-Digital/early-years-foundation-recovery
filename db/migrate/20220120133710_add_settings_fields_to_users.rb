class AddSettingsFieldsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :postcode, :string
    add_column :users, :ofsted_number, :string
  end
end
