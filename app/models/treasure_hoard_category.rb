class TreasureHoardCategory < ApplicationRecord
  CHALLENGE_RATINGS = %w[0-4 5-10 11-16 17+].freeze
  VALUABLE_TYPES = %w[gems art].freeze

  belongs_to :loot_table

  validates :challenge_rating, inclusion: { in: CHALLENGE_RATINGS }
  validates :weight, numericality: { only_integer: true, greater_than: 0 }
  validates :valuable_type, inclusion: { in: VALUABLE_TYPES }, allow_nil: true
  validates :valuable_min_count, :valuable_max_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :item_min, :item_max, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
end
