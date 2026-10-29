class MagicItemEntry < ApplicationRecord
  belongs_to :loot_table

  validates :item_type, :name, :link, presence: true
  validates :weight, numericality: { only_integer: true, greater_than: 0 }
end
