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
end
