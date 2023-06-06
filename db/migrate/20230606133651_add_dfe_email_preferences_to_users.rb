class AddDfeEmailPreferencesToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :dfe_email_opt_in, :boolean
  end
end
