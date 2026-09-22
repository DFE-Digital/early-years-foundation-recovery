class AddReleaseEmailTrackingToModuleReleases < ActiveRecord::Migration[7.2]
  def change
    change_table :module_releases, bulk: true do |t|
      t.string :contentful_entry_id
      t.datetime :release_email_queued_at
    end

    add_index :module_releases, :contentful_entry_id, unique: true
    remove_index :module_releases, :module_position, unique: true
  end
end
