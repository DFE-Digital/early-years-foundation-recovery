class ModuleRelease < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :module_position, presence: true, uniqueness: true

  belongs_to :release

  # @return [ActiveRecord::Relation<ModuleRelease>]
  def self.ordered
    order(:module_position)
  end
end
