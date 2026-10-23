require "rails_helper"

RSpec.describe "Campaign catalog", type: :system, js: true do
  def create_user(email: "player@example.com")
    User.new(email:, password: "password", password_confirmation: "password").tap do |user|
      user.build_profile
      user.save!
    end
  end

  def sign_in(user)
    visit new_user_session_path
    fill_in "Email", with: user.email
    fill_in "Password", with: "password"
    click_button "Sign in"

    expect(page).to have_css("button[aria-label='Account menu']")
    expect(page).to have_css("body[data-application-shell-ready='true']")
  end

  it "returns a signed-out visitor to the catalog after sign-in" do
    user = create_user

    visit campaigns_path

    expect(page).to have_current_path(new_user_session_path, ignore_query: true)
    fill_in "Email", with: user.email
    fill_in "Password", with: "password"
    click_button "Sign in"

    expect(page).to have_current_path(campaigns_path)
    expect(page).to have_content("no campaigns yet!")
  end

  it "returns a signed-out visitor to campaign creation after sign-in" do
    user = create_user

    visit new_campaign_path

    expect(page).to have_current_path(new_user_session_path, ignore_query: true)
    fill_in "Email", with: user.email
    fill_in "Password", with: "password"
    click_button "Sign in"

    expect(page).to have_current_path(new_campaign_path)
    expect(page).to have_field("Name")
  end

  it "renders an accessible empty catalog with a create action" do
    sign_in(create_user)
    visit campaigns_path

    expect(page).to have_selector("table thead th[scope='col']", text: "Name")
    expect(page).to have_selector("table tbody tr td", text: "no campaigns yet!")
    expect(page).to have_link("Create Campaign", href: "/campaigns/new")
    expect(page).to be_axe_clean
  end

  it "renders ordered DM and non-DM campaign names as non-interactive table text" do
    user = create_user
    [ [ "Zebra", true ], [ "apple", false ], [ "Éclair", false ] ].each do |name, is_dm|
      campaign = Campaign.create!(name:)
      CampaignMembership.create!(campaign:, profile: user.profile, is_dm:)
    end

    sign_in(user)
    visit campaigns_path

    expect(page.all("table tbody td").map(&:text)).to eq([ "apple", "Zebra", "Éclair" ])
    expect(page).to have_no_css("table tbody td a, table tbody td button")
    expect(page).to be_axe_clean
  end

  it "visually truncates a campaign name that exceeds the table width" do
    user = create_user
    campaign = Campaign.create!(name: "W" * 128)
    CampaignMembership.create!(campaign:, profile: user.profile, is_dm: true)

    sign_in(user)
    visit campaigns_path

    name_cell = find("table tbody td")
    expect(name_cell.evaluate_script("getComputedStyle(this).textOverflow")).to eq("ellipsis")
    expect(name_cell.evaluate_script("this.scrollWidth")).to be > name_cell.evaluate_script("this.clientWidth")
  end

  it "creates a campaign with the keyboard-accessible name-only form" do
    sign_in(create_user)
    visit campaigns_path

    click_link "Create Campaign"
    expect(page).to have_field("Name")
    expect(page).to have_no_field("Profile")
    expect(page).to be_axe_clean

    fill_in "Name", with: "  Cafe\u0301 Society  "
    click_button "Create campaign"

    expect(page).to have_current_path(campaigns_path)
    expect(page).to have_selector("[role='status']", text: "Campaign created successfully")
    expect(page).to have_css("table tbody td", text: "Café Society")
  end

  it "shows accessible validation and duplicate errors while retaining the entered name" do
    user = create_user
    Campaigns::Create.call(profile: user.profile, name: "The Wild Beyond")
    sign_in(user)
    visit new_campaign_path

    fill_in "Name", with: "AB"
    click_button "Create campaign"

    expect(page).to have_current_path(new_campaign_path)
    expect(page).to have_selector("[role='alert']", text: "There was a problem creating your campaign")
    expect(page).to have_field("Name", with: "AB")
    expect(page).to have_css("#campaign_name[aria-invalid='true'][aria-describedby~='campaign-name-error']")
    expect(page).to be_axe_clean

    fill_in "Name", with: "  THE WILD BEYOND  "
    click_button "Create campaign"

    expect(page).to have_text("You already DM a campaign with this name", count: 2)
    expect(page).to have_field("Name", with: "  THE WILD BEYOND  ")
    expect(page).to be_axe_clean
  end
end
