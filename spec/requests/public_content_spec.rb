require "rails_helper"

RSpec.describe "Public content", type: :request do
  let(:changelog) do
    [
      "# Changelog",
      "",
      "## Release <strong>notes</strong> & details",
      "",
      "- **Important** release",
      "- [Unsafe link](javascript:alert('unsafe'))",
      "",
      "<script>alert('unsafe')</script>",
      "",
      "A-long-unbroken-line-#{'x' * 300}",
      "",
      *Array.new(31) { |index| "- Release note #{index + 1}" },
      "",
      "[Release details](https://example.com/releases)"
    ].join("\n")
  end

  before do
    allow_any_instance_of(ApplicationController).to receive(:changelog_content).and_return(changelog)
  end

  it "renders the landing page publicly with safe semantic changelog content and placeholder stats" do
    get root_path

    expect(response).to have_http_status(:ok)

    document = Nokogiri::HTML5(response.body)
    expect_rendered_changelog(document)
    expect(document.css("main h1").map(&:text)).to eq([ "Changelog" ])
    expect(document.css("main h2").map(&:text)).to eq([ "Release <strong>notes</strong> & details", "Stats" ])
    expect(document.at_css(".changelog-preview + a.changelog-expand")).to be_present
    expect(document.css(".changelog-preview a")).to be_empty
    expect(document.css(".stats-list dt").map(&:text)).to eq([ "Unique session views", "Campaigns", "NPCs generated" ])
    expect(document.css(".stats-list dd").map(&:text)).to eq([ "45", "918", "2,415" ])
  end

  it "renders the complete safe semantic changelog publicly" do
    get changelog_path

    expect(response).to have_http_status(:ok)

    document = Nokogiri::HTML5(response.body)
    expect_rendered_changelog(document)
    expect(document.css("main h1").map(&:text)).to eq([ "Changelog" ])
    expect(document.at_css(".changelog")["class"].split).not_to include("changelog-preview")
    expect(document.at_css(".changelog a[href='https://example.com/releases']").text).to eq("Release details")
    expect(document.css(".changelog a").map { |link| link["href"].to_s }).not_to include(a_string_starting_with("javascript:"))
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
    expect(document.css("main h2").map(&:text)).to eq([ "Individual Treasure", "Treasure Hoard" ])
    expect(document.css("main section + hr + section").length).to eq(1)

    individual_select = document.at_css("select#individual-monster-cr")
    expect(individual_select.previous_element.text.strip).to eq("Monster CR")
    expect(individual_select.css("option").map(&:text)).to eq(
      [ "Select a CR", "1/8", "1/4", "1/2", *1.upto(16).map(&:to_s), "17+" ]
    )
    expect(individual_select.at_css("option[selected]")["value"]).to eq("")

    hoard_select = document.at_css("select#hoard-monster-cr")
    expect(hoard_select.previous_element.text.strip).to eq("Monster CR")
    expect(hoard_select.css("option").map(&:text)).to eq([ "Select a CR", "0-4", "5-10", "11-16", "17+" ])
    expect(hoard_select.at_css("option[selected]")["value"]).to eq("")
    expect(document.css("button[type='submit'][disabled]").map { |button| button.text.strip }).to eq([ "Generate", "Generate" ])

    bootstrapped_data = JSON.parse(document.at_css("[data-loot-hoard-data-value]")["data-loot-hoard-data-value"])
    expect(bootstrapped_data).to include(
      "categories" => [ include("challenge_rating" => "0-4", "weight" => 1) ],
      "valuables" => [ include("description" => "SQL-backed gem") ],
      "magic_items" => [ include("name" => "SQL-backed item", "link" => "https://example.com/item") ]
    )
  end

  def expect_rendered_changelog(document)
    changelog = document.at_css(".changelog")

    expect(changelog.at_css("h1").text).to eq("Changelog")
    expect(changelog.at_css("h2").text).to eq("Release <strong>notes</strong> & details")
    expect(changelog.css("h1 a, h2 a, h2 strong, script")).to be_empty
    expect(changelog.at_css("li strong").text).to eq("Important")
    expect(changelog.text).to include("<script>alert('unsafe')</script>", "Release note 31", "Release details")
    expect(changelog.text).not_to include("# Changelog", "## Release", "**Important**")
  end
end
