class ModuleRelease < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :module_position, presence: true, uniqueness: true
  validates :versions, presence: true

  belongs_to :release

  scope :ordered, -> { order(:module_position) }
end
