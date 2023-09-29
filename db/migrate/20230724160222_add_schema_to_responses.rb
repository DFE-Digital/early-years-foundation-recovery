class AddSchemaToResponses < ActiveRecord::Migration[7.0]
  def change
    change_table :responses, bulk: true do |t|
      t.jsonb :schema
    end
  end
end
