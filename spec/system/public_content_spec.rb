require "rails_helper"

RSpec.describe "Public content", type: :system, js: true do
  it "shows an escaped, clipped changelog preview before the statistics" do
    visit root_path

    within("main") do
      expect(page.all("h1, h2").map(&:text)).to eq([ "Changelog", "Stats" ])
      expect(page).to have_selector("h1 + .changelog-preview + a", text: "Expand")
      expect(page).to have_css("a.changelog-expand[href='#{changelog_path}'][target='_blank'][rel='noopener']", text: "Expand")
      expect(page).to have_css(".changelog-expand svg[aria-hidden='true']")
      expect(page).to have_text("HELLO WORLD")
      expect(page).to have_text("Unique session views")
      expect(page).to have_text("45")
      expect(page).to have_text("Campaigns")
      expect(page).to have_text("918")
      expect(page).to have_text("NPCs generated")
      expect(page).to have_text("2,415")
    end
    expect(page).to be_axe_clean

    preview = page.find(".changelog-preview")
    dimensions = page.evaluate_script(<<~JAVASCRIPT, preview)
      (function(element) {
        const style = window.getComputedStyle(element);
        return {
        height: element.getBoundingClientRect().height,
        lineHeight: parseFloat(style.lineHeight),
        overflowX: style.overflowX,
        overflowY: style.overflowY,
        whiteSpace: style.whiteSpace,
        overflowWrap: style.overflowWrap
        };
      })(arguments[0])
    JAVASCRIPT

    expect(dimensions["height"]).to be_within(0.1).of(dimensions["lineHeight"] * 30)
    expect(dimensions).to include("overflowX" => "clip", "overflowY" => "clip", "whiteSpace" => "pre-wrap", "overflowWrap" => "anywhere")
  end

  it "shows the full raw changelog without preview clipping" do
    visit changelog_path

    expect(page).to have_selector("h1", text: "Changelog")
    expect(page).to have_selector("pre.changelog", text: "HELLO WORLD")
    expect(page).not_to have_selector(".changelog-preview")
    expect(page).to be_axe_clean
  end
end
