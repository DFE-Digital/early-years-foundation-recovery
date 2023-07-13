class AddDfeEmailPreferencesToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :early_years_emails, :boolean
  end
end
