class AddFieldsToResponses < ActiveRecord::Migration[7.0]
  def change
    change_table :responses, bulk: true do |t|
      t.jsonb :schema
      t.jsonb :answer_text
      t.string :assessments_type
    end
  end
end
