class AddGuestVisitToResponses < ActiveRecord::Migration[7.1]
  def change
    add_column :responses, :guest_visit, :string
  end
end
