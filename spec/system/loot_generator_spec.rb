require "rails_helper"

RSpec.describe "Loot generator", type: :system, js: true do
  it "renders an accessible public page that reflows at narrow widths" do
    visit root_path
    click_link "Loot Generator"

    expect(page).to have_current_path(loot_path)
    expect(page.all("main h1, main h2").map(&:text)).to eq([ "Loot Generator", "Individual Treasure", "Treasure Horde" ])
    expect(page).to have_selector("section.individual-treasure + hr + section.treasure-horde")
    expect(page).to have_select("Monster CR", selected: "Select a CR", options: [ "Select a CR", "1/8", "1/4", "1/2", *1.upto(16).map(&:to_s), "17+" ])
    expect(page).to have_button("Generate", disabled: true)
    expect(page).to have_selector(".treasure-horde h2", text: "Treasure Horde")
    expect(page).to have_no_selector(".treasure-horde input, .treasure-horde select, .treasure-horde button")
    expect(page).to be_axe_clean

    page.current_window.resize_to(375, 812)

    expect(page.evaluate_script("document.documentElement.scrollWidth <= document.documentElement.clientWidth")).to be(true)
    expect(page).to be_axe_clean
  ensure
    page.current_window.resize_to(1400, 1400)
  end

  it "generates and replaces exactly three results while preserving button focus" do
    visit loot_path

    select "1/8", from: "Monster CR"
    expect(page).to have_button("Generate", disabled: false)

    stub_random([ 0.5, 0.25, 0.99, 0.5, 0.25, 0, 0, 0, 0, 0.5, 0.25, 0.3 ])
    find_button("Generate").send_keys(:enter)

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
    click_button "Generate"

    expect(page.all(".loot-result-list li").map(&:text)).to eq([ "Empty pockets" ] * 3)
    expect(page).to have_no_text("3 CP")
    expect(page.driver.browser.switch_to.active_element.text).to eq("Generate")
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
end
