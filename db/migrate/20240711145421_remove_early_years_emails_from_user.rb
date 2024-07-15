class RemoveEarlyYearsEmailsFromUser < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :early_years_emails, :boolean
  end
end
