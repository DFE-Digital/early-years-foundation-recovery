class AddFreetextResponses < ActiveRecord::Migration[7.1]
  def change
    add_column :responses, :text_input, :text
  end
end
