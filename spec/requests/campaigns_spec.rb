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

  it "requires sign-in for the new and create routes" do
    get new_campaign_path

    expect(response).to redirect_to(new_user_session_path)

    post campaigns_path, params: { campaign: { name: "Hidden Keep" } }

    expect(response).to redirect_to(new_user_session_path)
    expect(Campaign).not_to exist
  end

  it "returns a signed-out create attempt to the safe creation form after sign-in" do
    user = create_user

    post campaigns_path, params: { campaign: { name: "Hidden Keep" } }
    post user_session_path, params: { user: { email: user.email, password: "password" } }

    expect(response).to redirect_to(new_campaign_path)
    expect(Campaign).not_to exist
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

  it "creates a normalized campaign for the current profile and redirects with a success message" do
    user = create_user
    post user_session_path, params: { user: { email: user.email, password: "password" } }

    expect do
      post campaigns_path, params: {
        campaign: {
          name: "  Cafe\u0301 Society  ",
          profile_id: create_user(email: "other@example.com").profile.id,
          is_dm: false
        }
      }
    end.to change(Campaign, :count).by(1).and change(CampaignMembership, :count).by(1)

    expect(response).to redirect_to(campaigns_path)
    follow_redirect!
    expect(response.body).to include("Campaign created successfully", "Café Society")

    campaign = Campaign.last
    expect(campaign.name).to eq("Café Society")
    expect(campaign.campaign_memberships).to contain_exactly(
      have_attributes(profile: user.profile, is_dm: true)
    )
  end

  it "retains the submitted display value and associates inline errors with the name field" do
    user = create_user
    post user_session_path, params: { user: { email: user.email, password: "password" } }

    post campaigns_path, params: { campaign: { name: "  AB  " } }

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include('value="  AB  "')
    expect(response.body).to include('aria-invalid="true"')
    expect(response.body).to include('aria-describedby="campaign-name-error campaign-name-hint"')
    expect(response.body).to include("must contain between 3 and 128 characters")
    expect(Campaign).not_to exist
    expect(CampaignMembership).not_to exist
  end

  it "rejects controls and over-limit grapheme input through the form boundary" do
    user = create_user
    post user_session_path, params: { user: { email: user.email, password: "password" } }

    post campaigns_path, params: { campaign: { name: "Line one\nLine two" } }
    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include("must not contain control characters or line breaks")

    post campaigns_path, params: { campaign: { name: "a" * 129 } }
    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include("must contain between 3 and 128 characters")
    expect(Campaign).not_to exist
  end

  it "renders exact duplicate feedback and creates no additional records" do
    user = create_user
    Campaigns::Create.call(profile: user.profile, name: "Straße")
    post user_session_path, params: { user: { email: user.email, password: "password" } }

    expect do
      post campaigns_path, params: { campaign: { name: "  STRASSE  " } }
    end.to change(Campaign, :count).by(0).and change(CampaignMembership, :count).by(0)

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include("You already DM a campaign with this name")
    expect(response.body).to include('value="  STRASSE  "')
  end

  it "allows another profile to create the same normalized name" do
    first_user = create_user
    second_user = create_user(email: "other@example.com")
    Campaigns::Create.call(profile: first_user.profile, name: "Straße")
    post user_session_path, params: { user: { email: second_user.email, password: "password" } }

    expect do
      post campaigns_path, params: { campaign: { name: "STRASSE" } }
    end.to change(Campaign, :count).by(1).and change(CampaignMembership, :count).by(1)

    expect(response).to redirect_to(campaigns_path)
  end
end
