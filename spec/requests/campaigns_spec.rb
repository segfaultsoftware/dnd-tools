require "rails_helper"

RSpec.describe "Campaign catalog", type: :request do
  def create_user(email: "player@example.com")
    User.new(email:, password: "password", password_confirmation: "password").tap do |user|
      user.build_profile
      user.save!
    end
  end

  def create_campaign(profile:, name:, is_dm: false)
    Campaign.create!(name:).tap do |campaign|
      CampaignMembership.create!(campaign:, profile:, is_dm:)
    end
  end

  it "requires sign-in and returns to the protected catalog" do
    get campaigns_path

    expect(response).to redirect_to(new_user_session_path)

    user = create_user
    post user_session_path, params: { user: { email: user.email, password: "password" } }

    expect(response).to redirect_to(campaigns_path)
  end

  it "shows only the current profile's DM and non-DM campaigns in catalog order" do
    user = create_user
    other_user = create_user(email: "other@example.com")
    create_campaign(profile: user.profile, name: "Zebra", is_dm: true)
    create_campaign(profile: user.profile, name: "apple")
    create_campaign(profile: other_user.profile, name: "Hidden Campaign")

    post user_session_path, params: { user: { email: user.email, password: "password" } }
    get campaigns_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("apple", "Zebra")
    expect(response.body).not_to include("Hidden Campaign")
    expect(response.body.index("apple")).to be < response.body.index("Zebra")
  end
end
