class CreateLootTables < ActiveRecord::Migration[8.1]
  def change
    create_table :loot_tables do |t|
      t.references :campaign, foreign_key: true
      t.string :name, null: false
      t.string :table_type, null: false
      t.boolean :default, null: false, default: false

      t.timestamps
    end

    add_index :loot_tables, :table_type, unique: true, where: "\"default\" = TRUE", name: "index_default_loot_tables_on_type"
    add_index :loot_tables, [ :campaign_id, :table_type, :name ], unique: true, name: "index_campaign_loot_tables_on_identity"
    add_check_constraint :loot_tables,
      "(\"default\" = TRUE AND campaign_id IS NULL) OR (\"default\" = FALSE AND campaign_id IS NOT NULL)",
      name: "loot_tables_default_ownership"

    create_table :treasure_hoard_categories do |t|
      t.references :loot_table, null: false, foreign_key: true
      t.string :challenge_rating, null: false
      t.integer :weight, null: false
      t.integer :valuable_min_count
      t.integer :valuable_max_count
      t.string :valuable_value
      t.string :valuable_type
      t.string :item_type
      t.integer :item_min
      t.integer :item_max

      t.timestamps
    end

    add_index :treasure_hoard_categories, [ :loot_table_id, :challenge_rating ], name: "index_hoard_categories_on_table_and_cr"
    add_check_constraint :treasure_hoard_categories, "weight > 0", name: "treasure_hoard_categories_positive_weight"

    create_table :gemstone_art_entries do |t|
      t.references :loot_table, null: false, foreign_key: true
      t.string :entry_type, null: false
      t.string :value, null: false
      t.integer :weight, null: false
      t.string :description, null: false

      t.timestamps
    end

    add_index :gemstone_art_entries, [ :loot_table_id, :entry_type, :value ], name: "index_gemstone_art_entries_on_lookup"
    add_check_constraint :gemstone_art_entries, "weight > 0", name: "gemstone_art_entries_positive_weight"

    create_table :magic_item_entries do |t|
      t.references :loot_table, null: false, foreign_key: true
      t.string :item_type, null: false
      t.integer :weight, null: false
      t.string :name, null: false
      t.string :link, null: false

      t.timestamps
    end

    add_index :magic_item_entries, [ :loot_table_id, :item_type ], name: "index_magic_item_entries_on_lookup"
    add_check_constraint :magic_item_entries, "weight > 0", name: "magic_item_entries_positive_weight"
  end
end
