class AddDisplayWhatsNewToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :display_whats_new, :boolean, default: false
  end
end
