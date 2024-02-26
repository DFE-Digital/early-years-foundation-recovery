class RemoveSchemaFromResponses < ActiveRecord::Migration[7.0]
  def change
    change_table :responses, bulk: true do |t|
      t.remove :schema, type: :jsonb
    end
  end
end
