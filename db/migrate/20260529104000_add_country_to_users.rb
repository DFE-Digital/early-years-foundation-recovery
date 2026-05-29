class AddCountryToUsers < ActiveRecord::Migration[7.2]
  def change
    return if column_exists?(:users, :country)

    add_column :users, :country, :string
  end
end
