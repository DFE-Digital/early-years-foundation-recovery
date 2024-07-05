class AddGuestResponses < ActiveRecord::Migration[7.1]
  def change
    change_column_null :responses, :user_id, true

    change_table :responses, bulk: true do |t|
      t.references :visit, null: true, foreign_key: true
    end
  end
end
