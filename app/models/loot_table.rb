class LootTable < ApplicationRecord
  TYPES = %w[treasure_hoard_categories gemstone_art magic_items].freeze

  belongs_to :campaign, optional: true
  has_many :treasure_hoard_categories, dependent: :destroy
  has_many :gemstone_art_entries, dependent: :destroy
  has_many :magic_item_entries, dependent: :destroy

  validates :name, presence: true
  validates :table_type, inclusion: { in: TYPES }
  validates :table_type, uniqueness: { conditions: -> { where(default: true) } }, if: :default?
  validates :campaign, absence: true, if: :default?
  validates :campaign, presence: true, unless: :default?

  scope :defaults, -> { where(default: true) }

  def self.default_for!(table_type)
    defaults.find_by!(table_type: table_type)
  end
end
