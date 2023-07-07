class RemoveEarlyYearsEmailPreferencesFromUsers < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :early_years_emails, :boolean
  end
end
