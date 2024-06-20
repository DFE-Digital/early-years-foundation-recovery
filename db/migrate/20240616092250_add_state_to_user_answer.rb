class AddStateToUserAnswer < ActiveRecord::Migration[7.1]
  def change
    add_column :user_answers, :state, :string
  end
end
