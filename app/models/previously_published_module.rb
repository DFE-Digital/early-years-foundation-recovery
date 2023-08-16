class PreviouslyPublishedModule < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :module_position, presence: true, uniqueness: true

  # @return [ActiveRecord::Relation<PreviouslyPublishedModule>]
  def self.ordered
    order(:module_position)
  end
end
