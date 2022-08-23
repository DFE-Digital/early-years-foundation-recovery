# @abstract Extends ActiveYaml::Base so that objects can be defined
#   across a number of files in a folder
#
# @example
#   class Something < ActiveYaml::Base
#     extend YamlFolder
#     set_folder 'path/to/folder'
#   end
#
module YamlFolder
  # @overload full_path
  #   The full path to point at a folder rather than a file
  #
  # @return [String] "/srv/data/formative-questionnaires"
  def full_path
    File.join(actual_root_path, filename)
  end

  # Alias of `set_filename`
  #
  # @param name [String]
  #
  # @return [String]
  def set_folder(name)
    set_filename(name)
  end

private

  # @overload load_path
  #   Iterate over each YAML file in the folder and combine into a single hash
  #
  # @param path [String]
  #
  # @return [Hash]
  def load_path(path)
    results = Dir.glob(File.join(path, '*.yml')).map do |file|
      YAML.safe_load(ERB.new(File.read(file)).result)
    end
    results.compact!
    results.reduce(:merge)
  end
end
