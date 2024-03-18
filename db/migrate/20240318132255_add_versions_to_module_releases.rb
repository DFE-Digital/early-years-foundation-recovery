class AddVersionsToModuleReleases < ActiveRecord::Migration[7.1]
  def change
    add_column :module_releases, :versions, :jsonb
  end
end
