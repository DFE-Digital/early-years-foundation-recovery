class RemoveAttributesFromUsers < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :postcode, :string
    remove_column :users, :ofsted_number, :string
  end
end
