require "rails_helper"

RSpec.describe LootTable, type: :model do
  it "seeds the three default relational tables idempotently with every spreadsheet row" do
    2.times { load Rails.root.join("db/seeds/treasure_horde.rb") }

    expect(described_class.defaults.count).to eq(3)
    expect(TreasureHoardCategory.count).to eq(104)
    expect(GemstoneArtEntry.count).to eq(100)
    expect(MagicItemEntry.count).to eq(362)
    expect(MagicItemEntry.find_by!(name: "Potion of Watchful Rest").link).to eq("https://www.dndbeyond.com/magic-items/954156-potion-of-watchful-rest")

    category_table = described_class.default_for!("treasure_hoard_categories")
    expect(category_table.treasure_hoard_categories.group(:challenge_rating).count).to eq(
      "0-4" => 17, "5-10" => 29, "11-16" => 33, "17+" => 25
    )
    expect(category_table.treasure_hoard_categories.where(challenge_rating: "0-4", valuable_type: "gems", valuable_value: "10 gp")).to exist

    valuables_table = described_class.default_for!("gemstone_art")
    expect(valuables_table.gemstone_art_entries.where(entry_type: "Gemstone", value: "10 gp")).to exist

    magic_items_table = described_class.default_for!("magic_items")
    expect(magic_items_table.magic_item_entries.where(item_type: "A")).to exist
  end

  it "keeps default tables project-owned while allowing campaign-owned table records" do
    campaign = Campaign.create!(name: "Storm King's Thunder")

    expect(described_class.new(name: "Magic Items", table_type: "magic_items", default: true, campaign: campaign)).not_to be_valid
    expect(described_class.new(name: "Custom Magic Items", table_type: "magic_items", campaign: campaign)).to be_valid
  end
end
