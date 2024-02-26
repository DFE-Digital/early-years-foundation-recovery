class RemoveArchivedFromResponses < ActiveRecord::Migration[7.0]
  def change
    change_table :responses, bulk: true do |t|
      t.remove :archived, type: :boolean
    end
  end
end
