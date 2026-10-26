require "rails_helper"

RSpec.describe "Application shell", type: :system, js: true do
  it "provides the branded navigation and signed-out account links" do
    visit root_path

    expect(page).to have_title("TTRPG Tools & Campaign Management")
    expect(page).to have_css("header")
    expect(page).to have_css("aside[aria-label='Primary navigation']")
    expect(page).to have_text("TTRPG Tools & Campaign Management")
    expect(page).to have_css(".navigation-group h2", text: "D&D 5.5E TOOLS")
    expect(page).to have_text("NPC Generator")
    expect(page).to have_text("Magic Shop Generator")
    expect(page).to have_text("Loot Generator")
    expect(page).to have_text("Town Generator")
    expect(page).to have_link("Campaign Catalog", href: "/campaigns")
    expect(page).to have_link("Loot Generator", href: "/loot")
    expect(page).not_to have_link("NPC Generator")
    expect(page).to be_axe_clean

    expect(page).to have_link("Sign in", href: %r{/users/sign_in\?return_to=%2F\z})
    expect(page).to have_link("Sign up", href: %r{/users/sign_up\?return_to=%2F\z})
    expect(page).to have_css(".account-links")
    expect(page).not_to have_button("Account menu")
  end

  it "collapses the navigation at narrow widths and restores focus on Escape" do
    page.current_window.resize_to(375, 812)
    visit root_path

    expect(page).not_to have_css(".sidebar", visible: true)
    expect(page).to have_css("button[aria-label='Menu: open navigation'][aria-expanded='false']")

    page.find("button[aria-label='Menu: open navigation']").send_keys(:enter)

    expect(page).to have_css(".sidebar", visible: true)
    expect(page).to have_css("button[aria-label='Menu: close navigation'][aria-expanded='true']")

    page.driver.browser.action.send_keys(:escape).perform

    expect(page).not_to have_css(".sidebar", visible: true)
    expect(page.driver.browser.switch_to.active_element.attribute("aria-label")).to eq("Menu: open navigation")
    page.current_window.resize_to(1400, 1400)
  end

  it "renders the shell on authentication and changelog pages" do
    page.current_window.resize_to(1400, 1400)
    [ new_user_session_path, new_user_registration_path, "/changelog" ].each do |path|
      visit path

      expect(page).to have_css("header")
      expect(page).to have_css("aside[aria-label='Primary navigation']")
    end
  end
end
