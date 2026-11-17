require "rails_helper"

RSpec.describe "Loot generator", type: :system, js: true do
  before do
    seed_browser_loot_tables
  end

  it "renders an accessible public page that reflows at narrow widths" do
    visit root_path
    click_link "Loot Generator"

    expect(page).to have_current_path(loot_path)
    expect(page.all("main h1, main h2").map(&:text)).to eq([ "Loot Generator", "Individual Treasure", "Treasure Horde" ])
    expect(page).to have_selector("section.individual-treasure + hr + section.treasure-horde")
    within(".individual-treasure") do
      expect(page).to have_select("Monster CR", selected: "Select a CR", options: [ "Select a CR", "1/8", "1/4", "1/2", *1.upto(16).map(&:to_s), "17+" ])
      expect(page).to have_button("Generate", disabled: true)
    end
    expect(page).to have_selector(".treasure-horde h2", text: "Treasure Horde")
    within(".treasure-horde") do
      expect(page).to have_select("Monster CR", selected: "Select a CR", options: [ "Select a CR", "0-4", "5-10", "11-16", "17+" ])
      expect(page).to have_button("Generate", disabled: true)
    end
    expect(page).to be_axe_clean

    page.current_window.resize_to(375, 812)

    expect(page.evaluate_script("document.documentElement.scrollWidth <= document.documentElement.clientWidth")).to be(true)
    expect(page).to be_axe_clean
  ensure
    page.current_window.resize_to(1400, 1400)
  end

  it "generates and replaces exactly three results while preserving button focus" do
    visit loot_path

    within(".individual-treasure") do
      select "1/8", from: "Monster CR"
      expect(page).to have_button("Generate", disabled: false)
    end

    stub_random([ 0.5, 0.25, 0.99, 0.5, 0.25, 0, 0, 0, 0, 0.5, 0.25, 0.3 ])
    within(".individual-treasure") { find_button("Generate").send_keys(:enter) }

    expect(page.all(".loot-result-list li").map(&:text)).to eq([ "Empty pockets", "3 CP", "Empty pockets" ])
    expect(page).to have_css("button[aria-label='Copy Empty pockets to clipboard']", count: 2)
    expect(page).to have_css("button[aria-label='Copy 3 CP to clipboard']", count: 1)
    expect(page).to have_css(".loot-copy-button svg[aria-hidden='true']", count: 3)
    expect(page).to have_selector(".loot-results[role='status'][aria-live='polite'][aria-atomic='true']")
    expect(page.driver.browser.switch_to.active_element.text).to eq("Generate")
    expect(page).to be_axe_clean

    stub_clipboard
    copy_button = find("button[aria-label='Copy 3 CP to clipboard']")
    copy_button.send_keys(:enter)

    expect(page.evaluate_script("window.copiedLoot")).to eq("3 CP")
    expect(page).to have_selector("[data-loot-target='copyStatus']", text: "3 CP copied to clipboard", visible: :all)
    expect(copy_button.evaluate_script("parseFloat(getComputedStyle(this).marginLeft)")).to be_positive

    stub_random([ 0.5, 0.25, 0.99 ] * 3)
    within(".individual-treasure") { click_button "Generate" }

    expect(page.all(".loot-result-list li").map(&:text)).to eq([ "Empty pockets" ] * 3)
    expect(page).to have_no_text("3 CP")
    expect(page.driver.browser.switch_to.active_element.text).to eq("Generate")
  end

  it "generates, sorts, copies, and replaces three independent treasure hordes" do
    visit loot_path

    within(".treasure-horde") do
      select "0-4", from: "Monster CR"
      expect(page).to have_button("Generate", disabled: false)
    end
    expect(find("#individual-monster-cr").value).to eq("")

    stub_random([ 0.0, 0.3, 0.9, 0.1, 0.9, 0.1, 0.1, 0.0, 0.1 ])
    within(".treasure-horde") { find_button("Generate").send_keys(:enter) }

    rows = page.all(".treasure-horde-result")
    expect(rows.length).to eq(3)
    expect(rows[0]).to have_text("Empty hoard")
    expect(rows[0]).to have_no_selector("ul")
    expect(rows[1].all("li").map(&:text)).to eq([
      "10gp gem Azurite (opaque mottled deep blue)",
      "10gp gem Malachite (opaque striated light and dark green)"
    ])
    expect(rows[2].all("li").map(&:text)).to eq([
      "10gp gem Azurite (opaque mottled deep blue)",
      "10gp gem Azurite (opaque mottled deep blue)",
      "Philter of love"
    ])
    expect(rows[2]).to have_link("Philter of love", href: "https://example.com/philter")
    expect(page).to have_selector(".horde-results[role='status'][aria-live='polite'][aria-atomic='true']")
    expect(page.driver.browser.switch_to.active_element.attribute("data-loot-target")).to eq("hordeGenerateButton")
    expect(page).to be_axe_clean

    page.current_window.resize_to(375, 812)
    expect(page.evaluate_script("document.documentElement.scrollWidth <= document.documentElement.clientWidth")).to be(true)
    expect(page).to be_axe_clean
    page.current_window.resize_to(1400, 1400)

    stub_clipboard
    copy_button = rows[2].find("button[aria-label='Copy treasure horde 3 to clipboard']")
    copy_button.send_keys(:enter)
    expect(page.evaluate_script("window.copiedLoot")).to eq(<<~MARKDOWN.chomp)
      - 10gp gem Azurite (opaque mottled deep blue)
      - 10gp gem Azurite (opaque mottled deep blue)
      - [Philter of love](https://example.com/philter)
    MARKDOWN
    expect(page).to have_selector("[data-loot-target='hordeCopyStatus']", text: "Treasure horde 3 copied to clipboard", visible: :all)

    stub_clipboard_failure
    copy_button.send_keys(:enter)
    expect(page).to have_selector("[data-loot-target='hordeCopyStatus']", text: "Unable to copy treasure horde 3 to clipboard", visible: :all)

    stub_random([ 0.0, 0.0, 0.0 ])
    within(".treasure-horde") { click_button "Generate" }
    replaced_text = page.all(".treasure-horde-result").map(&:text).join(" ")
    expect(replaced_text).not_to include("Malachite")
    expect(replaced_text).not_to include("Philter")
    expect(page).to have_text("Empty hoard", count: 3)
  end

  it "uses weighted, bounded, inclusive, and replacement horde algorithms" do
    visit loot_path

    results = page.evaluate_async_script(<<~JAVASCRIPT)
      const done = arguments[arguments.length - 1];

      import("controllers/loot_controller").then(({ weightedSelection, sampleBoundedGaussian, inclusiveUniformInteger, generateTreasureHorde, hordeMarkdown }) => {
        const sequence = (values) => {
          let calls = 0;
          return { random: () => values[calls++], calls: () => calls };
        };
        const weighted = [{ name: "light", weight: 1 }, { name: "heavy", weight: 3 }];
        const rejected = sequence([Math.exp(-8), 0, Math.exp(-4.5), 0.5]);
        const data = {
          categories: [
            { challenge_rating: "test", weight: 1, valuable_type: "art", valuable_value: "25 gp", valuable_min_count: 2, valuable_max_count: 2, item_type: null },
            { challenge_rating: "magic", weight: 1, valuable_type: null, item_type: "A", item_min: 2, item_max: 2 },
            { challenge_rating: "empty", weight: 1, valuable_type: null, item_type: null }
          ],
          valuables: [{ entry_type: "Art", value: "25 gp", weight: 1, description: "Silver ewer" }],
          magic_items: [{ item_type: "A", weight: 1, name: "Potion", link: "https://example.com/potion" }]
        };
        const art = generateTreasureHorde(data, "test", sequence([0, 0, 0]).random);
        const magic = generateTreasureHorde(data, "magic", sequence([0, 0, 0, 0]).random);

        done({
          weightedFirst: weightedSelection(weighted, () => 0).name,
          weightedSecond: weightedSelection(weighted, () => 0.25).name,
          rejected: sampleBoundedGaussian(20, 40, rejected.random),
          rejectedCalls: rejected.calls(),
          fixed: sampleBoundedGaussian(7, 7, () => { throw new Error("random called") }),
          inclusiveMinimum: inclusiveUniformInteger(2, 6, () => 0),
          inclusiveMaximum: inclusiveUniformInteger(2, 6, () => 0.999999),
          art: art.map((entry) => entry.text),
          magic: magic.map((entry) => entry.text),
          markdown: hordeMarkdown(magic),
          empty: hordeMarkdown(generateTreasureHorde(data, "empty", () => 0))
        });
      }).catch((error) => done({ error: error.message }));
    JAVASCRIPT

    expect(results).not_to have_key("error")
    expect(results).to include(
      "weightedFirst" => "light", "weightedSecond" => "heavy",
      "rejected" => 20, "rejectedCalls" => 4, "fixed" => 7,
      "inclusiveMinimum" => 2, "inclusiveMaximum" => 6,
      "art" => [ "25gp art Silver ewer", "25gp art Silver ewer" ],
      "magic" => [ "Potion", "Potion" ],
      "markdown" => "- [Potion](https://example.com/potion)\n- [Potion](https://example.com/potion)",
      "empty" => "Empty hoard"
    )
  end

  it "uses the required bounded Gaussian and denomination algorithms" do
    visit loot_path

    results = page.evaluate_async_script(<<~JAVASCRIPT)
      const done = arguments[arguments.length - 1];

      import("controllers/loot_controller").then(({ MAXIMUM_CP_BY_CHALLENGE_RATING, samplePurse, generateCoins, formatCoins }) => {
        const sequence = (values) => {
          let calls = 0;
          return {
            random: () => values[calls++],
            calls: () => calls
          };
        };

        const oneDeviation = sequence([Math.exp(-0.5), 0]);
        const rounded = sequence([Math.exp(-0.0003125), 0]);
        const rejected = sequence([Math.exp(-8), 0, Math.exp(-0.5), 0.5]);
        const allCoins = sequence([0.99, 0.74, 0.49, 0.24, 0.99]);
        const overdraw = sequence([0.99]);

        const response = {
          maximums: MAXIMUM_CP_BY_CHALLENGE_RATING,
          oneDeviation: samplePurse(120, oneDeviation.random),
          rounded: samplePurse(120, rounded.random),
          rejected: samplePurse(120, rejected.random),
          rejectedCalls: rejected.calls(),
          orderedCoins: formatCoins(generateCoins(1111, allCoins.random)),
          emptyCoins: formatCoins(generateCoins(5, overdraw.random)),
          overdrawCalls: overdraw.calls()
        };

        done(response);
      }).catch((error) => done({ error: error.message }));
    JAVASCRIPT

    expect(results).not_to have_key("error")
    expect(results["maximums"]).to eq(
      "1/8" => 5, "1/4" => 50, "1/2" => 100, "1" => 300, "2" => 800,
      "3" => 1300, "4" => 1800, "5" => 2000, "6" => 4800, "7" => 7600,
      "8" => 10400, "9" => 13200, "10" => 16000, "11" => 20000,
      "12" => 56000, "13" => 92000, "14" => 128000, "15" => 164000,
      "16" => 200000, "17+" => 1600000
    )
    expect(results).to include(
      "oneDeviation" => 80,
      "rounded" => 61,
      "rejected" => 40,
      "rejectedCalls" => 4,
      "orderedCoins" => "1 PP, 1 GP, 1 SP, 1 CP",
      "emptyCoins" => "Empty pockets",
      "overdrawCalls" => 1
    )
  end

  def stub_random(values)
    page.execute_script(<<~JAVASCRIPT, values)
      window.originalMathRandom ||= Math.random;
      window.testRandomValues = arguments[0].slice();
      Math.random = () => window.testRandomValues.length > 0 ? window.testRandomValues.shift() : window.originalMathRandom();
    JAVASCRIPT
  end

  def stub_clipboard
    page.execute_script(<<~JAVASCRIPT)
      Object.defineProperty(navigator, "clipboard", {
        configurable: true,
        value: {
          writeText: (value) => {
            window.copiedLoot = value;
            return Promise.resolve();
          }
        }
      });
    JAVASCRIPT
  end

  def stub_clipboard_failure
    page.execute_script(<<~JAVASCRIPT)
      Object.defineProperty(navigator, "clipboard", {
        configurable: true,
        value: { writeText: () => Promise.reject(new Error("Clipboard unavailable")) }
      });
    JAVASCRIPT
  end

  def seed_browser_loot_tables
    category_table = LootTable.create!(name: "Treasure Hoard Categories", table_type: "treasure_hoard_categories", default: true)
    valuables_table = LootTable.create!(name: "Gemstones & Art", table_type: "gemstone_art", default: true)
    magic_items_table = LootTable.create!(name: "Magic Items", table_type: "magic_items", default: true)

    category_table.treasure_hoard_categories.create!([
      { challenge_rating: "0-4", weight: 1 },
      { challenge_rating: "0-4", weight: 1, valuable_type: "gems", valuable_value: "10 gp", valuable_min_count: 2, valuable_max_count: 2 },
      { challenge_rating: "0-4", weight: 1, item_type: "A", item_min: 1, item_max: 1 },
      { challenge_rating: "0-4", weight: 1, valuable_type: "gems", valuable_value: "10 gp", valuable_min_count: 2, valuable_max_count: 2, item_type: "A", item_min: 1, item_max: 1 }
    ])
    valuables_table.gemstone_art_entries.create!([
      { entry_type: "Gemstone", value: "10 gp", weight: 1, description: "Azurite (opaque mottled deep blue)" },
      { entry_type: "Gemstone", value: "10 gp", weight: 1, description: "Malachite (opaque striated light and dark green)" }
    ])
    magic_items_table.magic_item_entries.create!(item_type: "A", weight: 1, name: "Philter of love", link: "https://example.com/philter")
  end
end
