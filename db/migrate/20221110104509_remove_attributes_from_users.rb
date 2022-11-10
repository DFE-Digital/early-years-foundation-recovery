class RemoveAttributesFromUsers < ActiveRecord::Migration[7.0]
  def up
    change_table :users, bulk: true do |t|
      t.remove :postcode
      t.remove :ofsted_number
    end
  end

  def down
    change_table :users, bulk: true do |t|
      t.string :postcode
      t.string :ofsted_number
    end
  end
end
