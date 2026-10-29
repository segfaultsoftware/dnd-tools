require "rails_helper"

RSpec.describe "Public content", type: :request do
  let(:changelog) do
    [
      "# Release <strong>notes</strong> & details",
      "A-long-unbroken-line-#{'x' * 300}",
      *Array.new(31) { |index| "Release note #{index + 1}" }
    ].join("\n")
  end

  before do
    allow_any_instance_of(ApplicationController).to receive(:changelog_content).and_return(changelog)
  end

  it "renders the landing page publicly with escaped changelog content and placeholder stats" do
    get root_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("# Release &lt;strong&gt;notes&lt;/strong&gt; &amp; details")
    expect(response.body).not_to include("<strong>notes</strong>")
    expect(response.body).to include("Release note 31")
    expect(response.body).to include("Unique session views")
    expect(response.body).to include(">45<")
    expect(response.body).to include("Campaigns")
    expect(response.body).to include(">918<")
    expect(response.body).to include("NPCs generated")
    expect(response.body).to include(">2,415<")
  end

  it "renders the complete escaped changelog publicly" do
    get changelog_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("# Release &lt;strong&gt;notes&lt;/strong&gt; &amp; details")
    expect(response.body).not_to include("<strong>notes</strong>")
    expect(response.body).to include("Release note 31")
  end

  it "renders the loot generator publicly with the exact controls and page structure" do
    category_table = LootTable.create!(name: "Treasure Hoard Categories", table_type: "treasure_hoard_categories", default: true)
    valuables_table = LootTable.create!(name: "Gemstones & Art", table_type: "gemstone_art", default: true)
    magic_items_table = LootTable.create!(name: "Magic Items", table_type: "magic_items", default: true)
    category_table.treasure_hoard_categories.create!(challenge_rating: "0-4", weight: 1)
    valuables_table.gemstone_art_entries.create!(entry_type: "Gemstone", value: "10 gp", weight: 1, description: "SQL-backed gem")
    magic_items_table.magic_item_entries.create!(item_type: "A", weight: 1, name: "SQL-backed item", link: "https://example.com/item")

    get loot_path

    expect(response).to have_http_status(:ok)

    document = Nokogiri::HTML5(response.body)
    expect(document.css("main h1").map(&:text)).to eq([ "Loot Generator" ])
    expect(document.css("main h2").map(&:text)).to eq([ "Individual Treasure", "Treasure Horde" ])
    expect(document.css("main section + hr + section").length).to eq(1)

    individual_select = document.at_css("select#individual-monster-cr")
    expect(individual_select.previous_element.text.strip).to eq("Monster CR")
    expect(individual_select.css("option").map(&:text)).to eq(
      [ "Select a CR", "1/8", "1/4", "1/2", *1.upto(16).map(&:to_s), "17+" ]
    )
    expect(individual_select.at_css("option[selected]")["value"]).to eq("")

    horde_select = document.at_css("select#horde-monster-cr")
    expect(horde_select.previous_element.text.strip).to eq("Monster CR")
    expect(horde_select.css("option").map(&:text)).to eq([ "Select a CR", "0-4", "5-10", "11-16", "17+" ])
    expect(horde_select.at_css("option[selected]")["value"]).to eq("")
    expect(document.css("button[type='submit'][disabled]").map { |button| button.text.strip }).to eq([ "Generate", "Generate" ])

    bootstrapped_data = JSON.parse(document.at_css("[data-loot-horde-data-value]")["data-loot-horde-data-value"])
    expect(bootstrapped_data).to include(
      "categories" => [ include("challenge_rating" => "0-4", "weight" => 1) ],
      "valuables" => [ include("description" => "SQL-backed gem") ],
      "magic_items" => [ include("name" => "SQL-backed item", "link" => "https://example.com/item") ]
    )
  end
end
