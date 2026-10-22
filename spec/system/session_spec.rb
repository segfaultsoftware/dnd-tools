require "rails_helper"

RSpec.describe "Account sign-in", type: :system, js: true do
  let!(:user) do
    User.new(email: "sam@example.com", password: "password", password_confirmation: "password").tap do |created_user|
      created_user.build_profile
      created_user.save!
    end
  end

  it "supports remembered sign-in, current-browser sign-out, and keyboard-only password dialog control" do
    visit new_user_session_path

    expect(page).to be_axe_clean
    expect(page).to have_field("Remember me for three weeks")

    page.find_button("Forgot password?").send_keys(:enter)

    expect(page).to have_css("dialog[open]", text: "Not Yet Implemented")
    expect(page).to be_axe_clean
    expect(page.driver.browser.switch_to.active_element.text).to eq("Close")

    page.find_button("Close").send_keys(:enter)

    expect(page).not_to have_css("dialog[open]")
    expect(page.driver.browser.switch_to.active_element.text).to eq("Forgot password?")

    fill_in "Email", with: user.email
    fill_in "Password", with: "password"
    check "Remember me for three weeks"
    click_button "Sign in"

    expect(page).to have_button("Sign out", visible: :all)
    expect(page).to have_css("button[aria-label='Account menu'][aria-expanded='false']")
    expect(page).to be_axe_clean
    find("button[aria-label='Account menu']").click
    expect(page).to have_button("Sign out")
    expect(user.reload.remember_created_at).to be_present

    click_button "Sign out"

    expect(page).to have_link("Sign in")
    expect(page).not_to have_button("Account menu")
  end

  it "keeps a separately remembered browser signed in after sign-out elsewhere" do
    using_session(:first_remembered_browser) do
      visit new_user_session_path
      fill_in "Email", with: user.email
      fill_in "Password", with: "password"
      check "Remember me for three weeks"
      click_button "Sign in"

      expect(page).to have_button("Sign out", visible: :all)
      find("button[aria-label='Account menu']").click
      expect(page).to have_button("Sign out")
    end

    using_session(:second_remembered_browser) do
      visit new_user_session_path
      fill_in "Email", with: user.email
      fill_in "Password", with: "password"
      check "Remember me for three weeks"
      click_button "Sign in"

      expect(page).to have_button("Sign out", visible: :all)
      find("button[aria-label='Account menu']").click
      expect(page).to have_button("Sign out")
    end

    using_session(:first_remembered_browser) do
      click_button "Sign out"
    end

    using_session(:second_remembered_browser) do
      visit root_path

      find("button[aria-label='Account menu']").click
      expect(page).to have_button("Sign out")
    end
  end
end
