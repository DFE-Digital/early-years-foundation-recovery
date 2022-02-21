# Extends ActiveYaml::Base so that objects can be defined across a number of files in a folder
#
# Usage:
#   class Something < ActiveYaml::Base
#     extend YamlFolder
#     set_folder 'path/to/folder'
#   end

module YamlFolder
  # Override the full path to point at a folder rather than a file
  def full_path
    File.join(actual_root_path, filename)
  end

  # When loading from a folder, the set_filename is used, but aliased as set_folder
  # For that to work within this module, the method has to exist - hence this pass-through method
  def set_filename(name)
    super
  end
  alias_method :set_folder, :set_filename

  private
  # Loop through each file in the folder, extract a hash from each yaml file, and merge the hashes into a single hash
  def load_path(path)
    results = Dir.glob(File.join(path, "*.yml")).map do |file|
      YAML.load(ERB.new(File.read(file)).result)
    end
    results.compact!
    results.reduce(:merge)
  end
end
