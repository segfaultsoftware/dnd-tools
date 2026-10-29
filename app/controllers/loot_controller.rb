class LootController < ApplicationController
  def show
    category_table = LootTable.default_for!("treasure_hoard_categories")
    valuables_table = LootTable.default_for!("gemstone_art")
    magic_items_table = LootTable.default_for!("magic_items")

    @treasure_horde_data = {
      categories: category_table.treasure_hoard_categories.order(:id).map do |category|
        category.attributes.slice(
          "challenge_rating", "weight", "valuable_min_count", "valuable_max_count",
          "valuable_value", "valuable_type", "item_type", "item_min", "item_max"
        )
      end,
      valuables: valuables_table.gemstone_art_entries.order(:id).map do |entry|
        entry.attributes.slice("entry_type", "value", "weight", "description")
      end,
      magic_items: magic_items_table.magic_item_entries.order(:id).map do |entry|
        entry.attributes.slice("item_type", "weight", "name", "link")
      end
    }
  end
end
