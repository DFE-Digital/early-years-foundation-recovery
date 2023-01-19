class AddAccountClosedFieldsToUsers < ActiveRecord::Migration[7.0]
  def change
    change_table :users, bulk: true do |t|
      t.datetime :account_closed_at
      t.string :closed_reason
      t.string :closed_reason_custom
    end
  end
end
