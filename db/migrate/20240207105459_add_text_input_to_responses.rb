class AddTextInputToResponses < ActiveRecord::Migration[7.0]
  def change
    add_column :responses, :text_input, :text
  end
end
