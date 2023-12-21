class RenameIdTokenToGovOneIdInUsers < ActiveRecord::Migration[7.0]
  def change
    rename_column :users, :id_token, :gov_one_id
  end
end
