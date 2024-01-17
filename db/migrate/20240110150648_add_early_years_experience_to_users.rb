class AddEarlyYearsExperienceToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :early_years_experience, :string
  end
end
