class ModuleRelease < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :module_position, presence: true
  validates :contentful_entry_id, uniqueness: true, allow_nil: true

  belongs_to :release

  scope :ordered, -> { order(:module_position) }
end
