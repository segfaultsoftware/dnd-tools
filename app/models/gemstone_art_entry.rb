class GemstoneArtEntry < ApplicationRecord
  ENTRY_TYPES = %w[Gemstone Art].freeze

  belongs_to :loot_table

  validates :entry_type, inclusion: { in: ENTRY_TYPES }
  validates :value, :description, presence: true
  validates :weight, numericality: { only_integer: true, greater_than: 0 }
end
